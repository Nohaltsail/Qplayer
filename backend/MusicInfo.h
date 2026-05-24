#ifndef MUSICINFO_H
#define MUSICINFO_H

#include <QString>
#include <QtQml>

struct MusicInfo {
    Q_GADGET

public:
    Q_PROPERTY(QString title MEMBER title)
    Q_PROPERTY(QString artist MEMBER artist)
    Q_PROPERTY(QString album MEMBER album)
    Q_PROPERTY(QString coverArt MEMBER coverArt)

public:
    QString title;
    QString artist;
    QString album;
    QString coverArt;
};

Q_DECLARE_METATYPE(MusicInfo)

#endif