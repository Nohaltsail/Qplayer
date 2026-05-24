#include "PlayerController.h"
#include <QMetaType>

Q_DECLARE_METATYPE(SongInfo)
Q_DECLARE_METATYPE(SongInfo*)

PlayerController::PlayerController(QObject* parent)
    : QObject(parent), m_player(new QMediaPlayer(this)), m_audioOutput(new QAudioOutput(this)),
      m_currentSongInfo(new SongInfo()), m_currentIndex(-1) {
    m_player->setAudioOutput(m_audioOutput);

    connect(m_player, &QMediaPlayer::positionChanged, this, &PlayerController::positionChanged);
    connect(m_player, &QMediaPlayer::durationChanged, this, &PlayerController::durationChanged);
    connect(m_player, &QMediaPlayer::playbackStateChanged, this, &PlayerController::onPlaybackStateChanged);
    connect(m_player, &QMediaPlayer::mediaStatusChanged, this, &PlayerController::onMediaStatusChanged);
    connect(m_player, &QMediaPlayer::metaDataChanged, this, &PlayerController::onMetaDataChanged);
    m_appIconPath = "file:///" + QDir::current().absoluteFilePath("icons/title.png");
}

PlayerController::~PlayerController() {
    delete m_currentSongInfo;
}

void PlayerController::onMetaDataChanged() {
    qDebug() << "PlayerController::onMetaDataChanged() - Meta data changed signal received.";
    if (m_currentSongInfo && m_player) {
        if (m_currentIndex >= 0 && m_currentIndex < m_playlist.size()) {
            extractMetaData(*m_currentSongInfo);
            emit currentSongInfoChanged();

            m_currentMusicInfo.title = m_currentSongInfo->title;
            m_currentMusicInfo.artist = m_currentSongInfo->artist;
            m_currentMusicInfo.album = m_currentSongInfo->album;
            m_currentMusicInfo.coverArt = m_currentSongInfo->coverArt;

            emit currentMusicInfoChanged();
            qDebug() << "Updated Song Info from metadata - Title:" << m_currentSongInfo->title
                     << "Artist:" << m_currentSongInfo->artist << "Album:" << m_currentSongInfo->album
                     << "cover:" << m_currentMusicInfo.coverArt;
        }
    }
}

bool PlayerController::isPlaying() const {
    return m_player->playbackState() == QMediaPlayer::PlayingState;
}

qint64 PlayerController::position() const {
    return m_player->position();
}

void PlayerController::setPosition(qint64 position) {
    m_player->setPosition(position);
}

qint64 PlayerController::duration() const {
    return m_player->duration();
}

double PlayerController::volume() const {
    return m_audioOutput->volume();
}

void PlayerController::setVolume(double volume) {
    m_audioOutput->setVolume(volume);
    emit volumeChanged();
}

QString PlayerController::currentSong() const {
    if (m_currentIndex >= 0 && m_currentIndex < m_playlist.size()) {
        QUrl url = m_playlist[m_currentIndex];
        return QFileInfo(url.toLocalFile()).fileName();
    }
    return "未选择音乐";
}

QString PlayerController::getSongName(int index) const {
    if (index >= 0 && index < m_playlist.size()) {
        QUrl url = m_playlist[index];
        return QFileInfo(url.toLocalFile()).fileName();
    }
    return "未知的音乐";
}

void PlayerController::play() {
    if (m_currentIndex >= 0 && m_currentIndex < m_playlist.size()) {
        if (m_player->source() != m_playlist[m_currentIndex]) {
            m_player->setSource(m_playlist[m_currentIndex]);
        }
        m_player->play();
    }
}

void PlayerController::pause() {
    m_player->pause();
}

void PlayerController::stop() {
    m_player->stop();
}

void PlayerController::next() {
    if (m_playlist.isEmpty()) return;
    m_currentIndex = (m_currentIndex + 1) % m_playlist.size();
    emit currentIndexChanged();
    play();
}

void PlayerController::previous() {
    if (m_playlist.isEmpty()) return;
    m_currentIndex = (m_currentIndex - 1 + m_playlist.size()) % m_playlist.size();
    emit currentIndexChanged();
    play();
}

void PlayerController::playIndex(int index) {
    if (index >= 0 && index < m_playlist.size()) {
        m_currentIndex = index;
        emit currentIndexChanged();
        play();
    }
}

void PlayerController::addSong(const QUrl& url) {
    m_playlist.append(url);
    if (m_currentIndex == -1 && !m_playlist.isEmpty()) {
        m_currentIndex = 0;
    }
    emit playlistChanged();
    emit currentSongChanged();
}

void PlayerController::addFolder(const QUrl& folderUrl) {
    QDir dir(folderUrl.toLocalFile());
    QStringList filters = {"*.mp3", "*.wav", "*.flac", "*.ogg", "*.m4a"};
    auto files = dir.entryInfoList(filters, QDir::Files);
    for (const auto& file : files) {
        m_playlist.append(QUrl::fromLocalFile(file.absoluteFilePath()));
    }
    if (m_currentIndex == -1 && !m_playlist.isEmpty()) {
        m_currentIndex = 0;
    }
    emit playlistChanged();
    emit currentSongChanged();
}

void PlayerController::clearPlaylist() {
    m_playlist.clear();
    m_currentIndex = -1;
    m_player->stop();

    if (m_currentSongInfo) {
        m_currentSongInfo->title.clear();
        m_currentSongInfo->artist.clear();
        m_currentSongInfo->album.clear();
        m_currentSongInfo->coverArt = "qrc:/images/default_cover.png";
        m_currentSongInfo->fileName.clear();
        m_currentSongInfo->filePath.clear();
        m_currentSongInfo->duration = 0;
        m_currentSongInfo->fileSize = 0;
    }
    emit playlistChanged();
    emit currentSongChanged();
    emit currentIndexChanged();
    emit currentSongInfoChanged();
}

void PlayerController::onPlaybackStateChanged() {
    emit playingChanged();
    emit currentSongChanged();
}

void PlayerController::onMediaStatusChanged(QMediaPlayer::MediaStatus status) {
    if (status == QMediaPlayer::EndOfMedia) {
        next();
    }
}

void PlayerController::removeFromPlaylist(int index) {
    if (index < 0 || index >= m_playlist.size()) {
        qWarning() << "Invalid index for removal:" << index;
        return;
    }

    if (index == m_currentIndex) {
        stop();
    }

    m_playlist.removeAt(index);

    if (index < m_currentIndex) {
        m_currentIndex--;
    } else if (index == m_currentIndex && !m_playlist.isEmpty()) {
        if (m_currentIndex >= m_playlist.size()) {
            m_currentIndex = m_playlist.size() - 1;
        }
        if (m_currentIndex >= 0) {
            playIndex(m_currentIndex);
        }
    } else if (index == m_currentIndex && m_playlist.isEmpty()) {
        m_currentIndex = -1;
        if (m_currentSongInfo) {
            m_currentSongInfo->title.clear();
            m_currentSongInfo->artist.clear();
            m_currentSongInfo->album.clear();
            m_currentSongInfo->coverArt = "qrc:/images/default_cover.png";
            m_currentSongInfo->fileName.clear();
            m_currentSongInfo->filePath.clear();
            m_currentSongInfo->duration = 0;
            m_currentSongInfo->fileSize = 0;
        }
        emit currentSongInfoChanged();
    }

    emit playlistChanged();
    emit currentIndexChanged();
    qDebug() << "Removed song at index:" << index;
}

void PlayerController::showSongProperties(int index) {
    qDebug() << "showSongProperties called with index:" << index;
    if (index < 0 || index >= m_playlist.size()) {
        qWarning() << "Invalid index for song properties:" << index;
        return;
    }

    const QUrl& songUrl = m_playlist.at(index);
    QFileInfo fileInfo(songUrl.toLocalFile());
    if (!fileInfo.exists()) {
        qWarning() << "File does not exist:" << fileInfo.absoluteFilePath();
        return;
    }

    QString propertiesText;
    propertiesText += QString("文件名: %1\n").arg(fileInfo.fileName());
    propertiesText += QString("格式: %1\n").arg(fileInfo.suffix().toUpper());
    propertiesText += QString("文件大小: %1\n").arg(formatFileSize(fileInfo.size()));
    propertiesText += QString("创建时间: %1\n").arg(fileInfo.birthTime().toString("yyyy-MM-dd hh:mm:ss"));
    propertiesText += QString("修改时间: %1\n").arg(fileInfo.lastModified().toString("yyyy-MM-dd hh:mm:ss"));
    propertiesText += QString("文件路径: %1\n").arg(fileInfo.absoluteFilePath());

    if (index == m_currentIndex && m_player) {
        qint64 duration = m_player->duration();
        if (duration > 0) {
            propertiesText += QString("时长: %1\n").arg(formatDuration(duration));
        }

        auto metaData = m_player->metaData();
        QString title = metaData.value(QMediaMetaData::Title).toString();
        if (!title.isEmpty()) {
            propertiesText += QString("标题: %1\n").arg(title);
        }
        QString artist = metaData.value(QMediaMetaData::Author).toString();
        if (!artist.isEmpty()) {
            propertiesText += QString("艺术家: %1\n").arg(artist);
        }
        QString album = metaData.value(QMediaMetaData::AlbumTitle).toString();
        if (!album.isEmpty()) {
            propertiesText += QString("专辑: %1\n").arg(album);
        }
    }

    qDebug().noquote() << "\n=== 歌曲属性 ===\n" << propertiesText << "================\n";
    emit songPropertiesReady(propertiesText);
}

QString PlayerController::formatFileSize(qint64 bytes) const {
    if (bytes == 0) return "0 B";
    const QStringList units = {"B", "KB", "MB", "GB"};
    double size = bytes;
    int unitIndex = 0;
    while (size >= 1024.0 && unitIndex < units.size() - 1) {
        size /= 1024.0;
        unitIndex++;
    }
    return QString("%1 %2").arg(size, 0, 'f', 1).arg(units[unitIndex]);
}

QString PlayerController::formatDuration(qint64 milliseconds) const {
    if (milliseconds <= 0) return "00:00";
    qint64 seconds = milliseconds / 1000;
    qint64 minutes = seconds / 60;
    seconds = seconds % 60;
    return QString("%1:%2").arg(minutes, 2, 10, QLatin1Char('0')).arg(seconds, 2, 10, QLatin1Char('0'));
}

void PlayerController::updateSongInfo(int index) {
    if (index < 0 || index >= m_playlist.size()) {
        return;
    }

    const QUrl& songUrl = m_playlist.at(index);
    QFileInfo fileInfo(songUrl.toLocalFile());

    m_currentSongInfo->fileName = fileInfo.fileName();
    m_currentSongInfo->filePath = fileInfo.absoluteFilePath();
    m_currentSongInfo->fileSize = fileInfo.size();

    QString fileName = fileInfo.completeBaseName();
    m_currentSongInfo->title = fileName;
    m_currentSongInfo->artist = "未知艺术家";
    m_currentSongInfo->album = "未知专辑";

    m_currentSongInfo->coverArt = findCoverArt(fileInfo.absoluteFilePath());

    emit currentSongInfoChanged();
}

void PlayerController::extractMetaData(SongInfo& info) {
    if (!m_player) return;

    auto metaData = m_player->metaData();

    QString title = metaData.value(QMediaMetaData::Title).toString();
    if (!title.isEmpty()) {
        info.title = title;
    }

    QString artist = metaData.value(QMediaMetaData::Author).toString();
    if (artist.isEmpty()) {
        artist = metaData.value(QMediaMetaData::AlbumArtist).toString();
    }
    if (artist.isEmpty()) {
        artist = metaData.value(QMediaMetaData::ContributingArtist).toString();
    }
    if (!artist.isEmpty()) {
        info.artist = artist;
    }

    QString album = metaData.value(QMediaMetaData::AlbumTitle).toString();
    if (!album.isEmpty()) {
        info.album = album;
    }

    qint64 duration = metaData.value(QMediaMetaData::Duration).toLongLong();
    if (duration > 0) {
        info.duration = duration;
    }

    QVariant metaImg = metaData.value(QMediaMetaData::ThumbnailImage);
    QString uniqueName = QString("%1_cover.png").arg(getSongName(m_currentIndex));
    if (metaImg.isValid()) {
        QImage img = metaImg.value<QImage>();
        QString imageDefaultPath = QDir::current().absoluteFilePath("icons/app_icon.png");
        if (!img.isNull()) {
            QString imagePath = QDir::current().absoluteFilePath(uniqueName);

            QDir().mkpath(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));

            if (img.save(imagePath, "PNG")) {
                info.coverArt = "file:///" + imagePath;
                qDebug() << "Cover art saved to:" << imagePath;
            } else {
                qDebug() << "Failed to save cover art, using default";
            }
        } else {
            qDebug() << "Image is null, using default cover art";
        }
    } else {
        info.coverArt = "";
    }
}

QString PlayerController::findCoverArt(const QString& filePath) const {
    QFileInfo fileInfo(filePath);
    QDir dir = fileInfo.dir();
    QString baseName = fileInfo.completeBaseName();

    QStringList coverNames = {"cover", "folder", "front", "albumart", "album", baseName};
    QStringList imageExtensions = {"*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif"};

    for (const QString& coverName : coverNames) {
        for (const QString& ext : imageExtensions) {
            QString pattern = coverName + ext.mid(1);
            if (dir.exists(pattern)) {
                return QUrl::fromLocalFile(dir.filePath(pattern)).toString();
            }
        }
    }

    auto imageFiles = dir.entryInfoList(imageExtensions, QDir::Files);
    if (!imageFiles.isEmpty()) {
        return QUrl::fromLocalFile(imageFiles.first().absoluteFilePath()).toString();
    }

    return "qrc:/default_cover.png";
}

SongInfo* PlayerController::getSongInfo(int index) const {
    if (index < 0 || index >= m_playlist.size()) {
        return nullptr;
    }

    SongInfo* info = new SongInfo();
    const QUrl& songUrl = m_playlist.at(index);
    QFileInfo fileInfo(songUrl.toLocalFile());

    info->fileName = fileInfo.fileName();
    info->filePath = fileInfo.absoluteFilePath();
    info->fileSize = fileInfo.size();

    QString fileName = fileInfo.completeBaseName();
    info->title = fileName;
    info->artist = "未知艺术家";
    info->album = "未知专辑";
    info->coverArt = findCoverArt(fileInfo.absoluteFilePath());

    return info;
}