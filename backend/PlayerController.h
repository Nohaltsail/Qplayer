#ifndef PLAYERCONTROLLER_H
#define PLAYERCONTROLLER_H

#include <QAudioOutput>
#include <QDebug>
#include <QDir>
#include <QEventLoop>
#include <QFileInfo>
#include <QImage>
#include <QList>
#include <QMediaMetaData>
#include <QMediaPlayer>
#include <QMessageBox>
#include <QObject>
#include <QString>
#include <QTimer>
#include <QUrl>
#include "MusicInfo.h"

struct SongInfo {
    QString title;
    QString artist;
    QString album;
    QString coverArt;
    QString fileName;
    QString filePath;
    qint64 duration;
    qint64 fileSize;

    SongInfo() : duration(0), fileSize(0) {}
};

class PlayerController : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool playing READ isPlaying NOTIFY playingChanged)
    Q_PROPERTY(qint64 position READ position WRITE setPosition NOTIFY positionChanged)
    Q_PROPERTY(qint64 duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(double volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(QString currentSong READ currentSong NOTIFY currentSongChanged)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(int playlistCount READ playlistCount NOTIFY playlistChanged)
    Q_PROPERTY(SongInfo* currentSongInfo READ currentSongInfo NOTIFY currentSongInfoChanged)
    Q_PROPERTY(MusicInfo currentMusicInfo READ currentMusicInfo NOTIFY currentMusicInfoChanged)
    Q_PROPERTY(QString appIconPath READ appIconPath CONSTANT)

public:
    explicit PlayerController(QObject* parent = nullptr);
    ~PlayerController();

    bool isPlaying() const;
    qint64 position() const;
    void setPosition(qint64 position);
    qint64 duration() const;
    double volume() const;
    void setVolume(double volume);
    QString currentSong() const;
    int currentIndex() const {
        return m_currentIndex;
    }
    int playlistCount() const {
        return m_playlist.size();
    }
    SongInfo* currentSongInfo() const {
        return m_currentSongInfo;
    }
    MusicInfo currentMusicInfo() const {
        return m_currentMusicInfo;
    }
    QString appIconPath() const {
        return m_appIconPath;
    }

    Q_INVOKABLE QString getSongName(int index) const;
    Q_INVOKABLE void showSongProperties(int index);
    Q_INVOKABLE SongInfo* getSongInfo(int index) const;

public slots:
    void play();
    void pause();
    void stop();
    void next();
    void previous();
    void playIndex(int index);
    void removeFromPlaylist(int index);
    void addSong(const QUrl& url);
    void addFolder(const QUrl& folderUrl);
    void clearPlaylist();

private slots:
    void onPlaybackStateChanged();
    void onMediaStatusChanged(QMediaPlayer::MediaStatus status);
    void onMetaDataChanged();

signals:
    void playingChanged();
    void positionChanged();
    void durationChanged();
    void volumeChanged();
    void currentSongChanged();
    void currentIndexChanged();
    void playlistChanged();
    void songPropertiesReady(const QString& properties);
    void currentSongInfoChanged();
    void currentMusicInfoChanged();

private:
    QMediaPlayer* m_player;
    QAudioOutput* m_audioOutput;
    QList<QUrl> m_playlist;
    SongInfo* m_currentSongInfo;
    MusicInfo m_currentMusicInfo;
    QString m_appIconPath;
    QString formatFileSize(qint64 bytes) const;
    QString formatDuration(qint64 milliseconds) const;
    void updateSongInfo(int index);
    void extractMetaData(SongInfo& info);
    QString findCoverArt(const QString& filePath) const;

    int m_currentIndex = -1;
};

#endif