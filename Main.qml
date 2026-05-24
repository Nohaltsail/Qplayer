import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    title: "QPlayer - Modern Music Player"

    minimumWidth: 600
    minimumHeight: 600

    Connections {
        target: playerController
        onSongPropertiesReady: {
            propertiesTextArea.text = properties
            propertiesDialog.open()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            ColumnLayout {
                Layout.preferredWidth: 400
                Layout.topMargin: -50
                spacing: 20

                RowLayout {
                    id: titleContainer
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15

                    Item {
                        id: logoItem
                        width: 44
                        height: 44

                        Rectangle {
                            id: glowEffect
                            anchors.centerIn: parent
                            width: 42
                            height: 42
                            radius: 21
                            color: "transparent"
                            border.color: "#852813"
                            border.width: 2
                            opacity: 0.6

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                running: true
                                NumberAnimation { from: 0.3; to: 0.8; duration: 1500; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: 0.8; to: 0.3; duration: 1500; easing.type: Easing.InOutQuad }
                            }
                        }

                        Image {
                            id: logoImage
                            anchors.centerIn: parent
                            width: 36
                            height: 36
                            source: playerController.appIconPath
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            antialiasing: true
                            mipmap: true

                            RotationAnimation on rotation {
                                from: 0
                                to: 360
                                duration: 4000
                                loops: Animation.Infinite
                                running: true
                                easing.type: Easing.Linear
                            }
                        }
                    }

                    Label {
                        text: "QPlayer"
                        font.pixelSize: 32
                        font.bold: true
                        font.family: "Segoe UI"
                        color: "white"
                        Layout.alignment: Qt.AlignVCenter

                        OpacityAnimator on opacity {
                            from: 0
                            to: 1
                            duration: 1000
                            running: true
                        }
                    }
                }

                Label {
                    text: playerController.currentSong
                    font.pixelSize: 16
                    color: "white"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                }

                Rectangle {
                    id: volumePanel
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    color: "#2a2a2a"
                    border.color: "#444"
                    border.width: 1
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        Item {
                            id: rootItem
                            Layout.preferredWidth: 180
                            Layout.fillHeight: true

                            property bool hasValidSongInfo:
                                (playerController.currentSongInfo &&
                                    (playerController.currentSongInfo.title ||
                                        playerController.currentSongInfo.artist ||
                                        playerController.currentSongInfo.album) ||
                                        playerController.currentSongInfo.coverArt) ||
                                (playerController.currentSong)

                            Column {
                                id: contentColumn
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8
                                visible: rootItem.hasValidSongInfo

                                Rectangle {
                                    id: albumArtContainer
                                    width: 60
                                    height: 60
                                    radius: 6
                                    color: "#3a3a3a"

                                    Image {
                                        id: coverImage
                                        anchors.fill: parent

                                        source: playerController.currentMusicInfo?.coverArt || ""
                                        fillMode: Image.PreserveAspectCrop
                                        opacity: 0.9

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 40
                                            height: 40
                                            radius: 4
                                            color: "transparent"
                                            border.color: "#2b2b2c"
                                            border.width: 2
                                            visible: coverImage.status !== Image.Ready

                                            Text {
                                                anchors.centerIn: parent
                                                text: "♪"
                                                color: "#666"
                                                font.pixelSize: 40
                                            }
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width
                                    spacing: 4

                                    Text {
                                        id: songTitleText
                                        width: parent.width

                                        text: playerController.currentMusicInfo?.title || playerController.currentSong || ""

                                        visible: text.length > 0
                                        color: "white"
                                        font.pixelSize: 14
                                        font.bold: true
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }

                                    Text {
                                        id: artistText
                                        width: parent.width
                                        text: playerController.currentMusicInfo?.artist || ""
                                        visible: text.length > 0
                                        color: "#bbb"
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }

                                    Text {
                                        id: albumText
                                        width: parent.width
                                        text: playerController.currentMusicInfo?.album || ""
                                        visible: text.length > 0
                                        color: "#888"
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }

                                    Row {
                                        id: progressRow
                                        width: parent.width
                                        spacing: 8
                                        topPadding: 4

                                        visible: playerController.duration > 0

                                        Text {
                                            text: formatTime(playerController.position)
                                            color: "#1DB954"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        Text {
                                            text: "/"
                                            color: "#666"
                                            font.pixelSize: 10
                                        }

                                        Text {
                                            text: formatTime(playerController.duration)
                                            color: "#666"
                                            font.pixelSize: 10
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: 1
                                color: "#444"
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Row {
                                id: waveRow
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 3

                                Repeater {
                                    id: waveRepeater
                                    model: 24

                                    Item {
                                        width: 8
                                        height: parent.parent ? parent.parent.height - 20 : 100

                                        property real barHeight: 10

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            width: 6
                                            height: parent.barHeight
                                            radius: 2
                                            color: Qt.hsva(0.05 + index / waveRepeater.count * 0.1, 0.9, 0.95, 1)
                                        }
                                    }
                                }
                            }

                            Timer {
                                id: waveTimer
                                interval: 100
                                running: playerController.playing
                                repeat: true
                                onTriggered: {

                                    for (let i = 0; i < waveRepeater.count; i++) {
                                        let item = waveRepeater.itemAt(i);
                                        if (item) {

                                            let center = waveRepeater.count / 2;
                                            let dist = Math.abs(i - center);
                                            let base = (1 - dist / center) * 0.8 + 0.2;
                                            let noise = Math.random() * 0.5;
                                            let h = (base + noise) * (waveRow.height * 0.7) + 10;
                                            item.barHeight = h;
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            id: volumeArea
                            Layout.preferredWidth: 28
                            Layout.fillHeight: true

                            Label {
                                id: volLabel
                                text: "音量"
                                color: "#bbb"
                                font.pixelSize: 9
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Label {
                                id: percentLabel
                                text: Math.round(playerController.volume * 100) + "%"
                                color: "#888"
                                font.pixelSize: 8
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.top: volLabel.bottom
                                anchors.bottom: percentLabel.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 20
                                hoverEnabled: true

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 2
                                    height: parent.height
                                    radius: 1
                                    color: "#555"
                                }

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 2
                                    height: playerController.volume * parent.height
                                    radius: 1
                                    color: "#1DB954"
                                }

                                Rectangle {
                                    id: handle
                                    property real yPos: parent.height * (1 - playerController.volume)
                                    x: parent.width / 2 - width / 2
                                    y: Math.max(0, Math.min(parent.height - height, yPos))
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: mouseArea.containsMouse || mouseArea.pressed ? "#1ed760" : "#1DB954"
                                    smooth: true
                                }

                                onPressed: updateVolume(mouse.y)
                                onPositionChanged: {
                                    if (pressed) updateVolume(mouse.y);
                                }

                                function updateVolume(y) {

                                    var ratio = 1 - (y / parent.height);
                                    ratio = Math.max(0, Math.min(1, ratio));

                                    playerController.volume = ratio;

                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15

                    RoundButton {
                        implicitWidth: 50
                        implicitHeight: 50
                        onClicked: playerController.previous()

                        background: Rectangle {
                            color: {
                                if (parent.down) return "#4a3a80"
                                else if (parent.hovered) return "#6d54a8"
                                else return "#5a4597"
                            }
                            radius: Math.min(parent.width, parent.height) / 2
                            border.color: parent.down ? "#3a2d6b" : "transparent"
                            border.width: parent.down ? 2 : 0

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            Behavior on radius {
                                NumberAnimation { duration: 100 }
                            }
                        }

                        contentItem: Text {
                            text: "◀◀"
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 16
                            font.bold: true
                            opacity: parent.enabled ? 1.0 : 0.5
                        }

                    }

                    RoundButton {
                        text: playerController.playing ? "❚❚" : "▶"
                        radius: 30
                        implicitWidth: 60
                        implicitHeight: 60
                        font.pixelSize: playerController.playing ? 15 : 24

                        onClicked: playerController.playing ? playerController.pause() : playerController.play()

                        background: Rectangle {
                            color: parent.hovered ? "#a53a20" : "#852813"
                            radius: parent.radius
                            border.color: parent.down ? "#6a1f0f" : "transparent"
                            border.width: parent.down ? 2 : 0

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: parent.font.pixelSize
                        }
                    }

                    RoundButton {
                        implicitWidth: 50
                        implicitHeight: 50
                        onClicked: playerController.next()

                        background: Rectangle {
                            color: {
                                if (parent.down) return "#4a3a80"
                                else if (parent.hovered) return "#6d54a8"
                                else return "#5a4597"
                            }
                            radius: Math.min(parent.width, parent.height) / 2
                            border.color: parent.down ? "#3a2d6b" : "transparent"
                            border.width: parent.down ? 2 : 0

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            Behavior on radius {
                                NumberAnimation { duration: 100 }
                            }
                        }

                        contentItem: Text {
                            text: "▶▶"
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 16
                            font.bold: true
                            opacity: parent.enabled ? 1.0 : 0.5
                        }

                    }

                    RoundButton {
                        text: "■"
                        radius: 25
                        implicitWidth: 50
                        implicitHeight: 50
                        font.pixelSize: 18

                        onClicked: playerController.stop()

                        background: Rectangle {
                            color: parent.hovered ? "#c44545" : "#a83535"
                            radius: parent.radius
                            border.color: parent.down ? "#8a2b2b" : "transparent"
                            border.width: parent.down ? 2 : 0

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: parent.font.pixelSize
                            font.bold: true
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Slider {
                        id: progressSlider
                        Layout.fillWidth: true
                        Layout.preferredHeight: 12

                        from: 0
                        to: Math.max(1, playerController.duration)
                        value: playerController.position
                        enabled: playerController.duration > 0

                        onMoved: {

                            if (typeof playerController.setPosition === "function") {
                                playerController.setPosition(value)
                            }

                            else if (playerController.position !== undefined) {
                                playerController.position = value
                            }

                            else if (playerController.seek !== undefined) {
                                playerController.seek(value)
                            }
                        }

                        handle: null
                        background: null

                        contentItem: Item {
                            implicitHeight: 1

                            Rectangle {
                                anchors.fill: parent
                                color: "#666666"
                                antialiasing: false
                            }

                            Rectangle {
                                width: progressSlider.visualPosition * parent.width
                                height: parent.height
                                color: "#fa4627"
                                antialiasing: false
                            }

                            Rectangle {
                                x: Math.max(4, Math.min(parent.width - 4, progressSlider.visualPosition * parent.width)) - 4
                                y: (parent.height - 8) / 2
                                width: 8
                                height: 8
                                radius: 4
                                color: "#ffffff"
                                antialiasing: true

                                scale: progressSlider.pressed ? 1.1 : 1.0
                                Behavior on scale { NumberAnimation { duration: 80 } }
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: formatTime(playerController.position)
                            color: "#aaa"
                            font.pixelSize: 12
                        }

                        Item { Layout.fillWidth: true }

                        Label {
                            text: formatTime(playerController.duration)
                            color: "#aaa"
                            font.pixelSize: 12
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 15

                    Column {
                        width: window.width / 2
                        spacing: 10

                        Button {
                            text: "📁 文件夹导入"
                            width: parent.width
                            onClicked: folderDialog.open()
                            background: Rectangle {
                                color: "#333"
                                radius: 8
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: "🎵 添加音乐文件"
                            width: parent.width
                            onClicked: fileDialog.open()
                            background: Rectangle {
                                color: "#333"
                                radius: 8
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: "🗑️ 清空播放列表"
                            width: parent.width
                            onClicked: {

                                playerController.clearPlaylist()
                                console.log("Clear playlist clicked")
                            }
                            background: Rectangle {
                                color: "#d32f2f"
                                radius: 8
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: window.height / 4
                        color: "#2a2a2a"
                        radius: 8

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 5

                            Label {
                                text: "播放列表"
                                font.pixelSize: 16
                                font.bold: true
                                color: "white"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            ListView {
                                id: playlistView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                model: playerController.playlistCount
                                clip: true

                                property int rightClickedIndex: -1

                                delegate: Rectangle {
                                    id: songItem
                                    width: playlistView.width
                                    height: 35
                                    color: {
                                        if (index === playerController.currentIndex) {
                                            "#1DB954"
                                        } else if (index === playlistView.rightClickedIndex) {
                                            "#555"
                                        } else {
                                            "transparent"
                                        }
                                    }
                                    radius: 4

                                    Popup {
                                        id: contextMenu
                                        x: mouseArea.mouseX
                                        y: mouseArea.mouseY
                                        width: 120
                                        height: contentColumn.implicitHeight + 20
                                        modal: true
                                        focus: true
                                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                                        dim: false

                                        background: Rectangle {
                                            color: "#333"
                                            radius: 5
                                            border.color: "#555"
                                        }

                                        onAboutToShow: {
                                            playlistView.rightClickedIndex = index
                                        }

                                        onClosed: {
                                            playlistView.rightClickedIndex = -1
                                        }

                                        Column {
                                            id: contentColumn
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 5

                                            Button {
                                                text: "属性"
                                                width: parent.width
                                                height: 30
                                                background: Rectangle {
                                                    color: "#444"
                                                    radius: 3
                                                }
                                                contentItem: Text {
                                                    text: parent.text
                                                    color: "white"
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                onClicked: {
                                                    playerController.showSongProperties(index)
                                                    contextMenu.close()
                                                }
                                            }

                                            Button {
                                                text: "播放"
                                                width: parent.width
                                                height: 30
                                                background: Rectangle {
                                                    color: "#444"
                                                    radius: 3
                                                }
                                                contentItem: Text {
                                                    text: parent.text
                                                    color: "white"
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                onClicked: {
                                                    playerController.playIndex(index)
                                                    contextMenu.close()
                                                }
                                            }

                                            Button {
                                                text: "移除"
                                                width: parent.width
                                                height: 30
                                                background: Rectangle {
                                                    color: "#d32f2f"
                                                    radius: 3
                                                }
                                                contentItem: Text {
                                                    text: parent.text
                                                    color: "white"
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                onClicked: {
                                                    removeConfirmationDialog.index = index
                                                    removeConfirmationDialog.open()
                                                    contextMenu.close()
                                                }
                                            }
                                        }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        spacing: 10

                                        Label {
                                            text: index + 1
                                            color: {
                                                if (index === playerController.currentIndex) "white"
                                                else if (index === playlistView.rightClickedIndex) "white"
                                                else "#888"
                                            }
                                            font.pixelSize: 12
                                            Layout.preferredWidth: 100
                                        }

                                        Label {
                                            text: playerController.getSongName(index)
                                            color: {
                                                if (index === playerController.currentIndex) "white"
                                                else if (index === playlistView.rightClickedIndex) "white"
                                                else "#ddd"
                                            }
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                                        onClicked: function(mouse) {
                                            if (mouse.button === Qt.LeftButton) {

                                                playerController.playIndex(index)

                                                playlistView.rightClickedIndex = -1
                                            } else if (mouse.button === Qt.RightButton) {

                                                contextMenu.x = mouse.x
                                                contextMenu.y = mouse.y
                                                contextMenu.open()
                                            }
                                        }
                                    }
                                }

                                ScrollBar.vertical: ScrollBar {
                                    policy: ScrollBar.AlwaysOn
                                }
                            }
                        }
                    }

                }
            }
        }
    }

    Dialog {
        id: removeConfirmationDialog
        property int index: -1

        title: "Remove?"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No

        Label {
            text: "Accept remove？"
        }
        onAccepted: playerController.removeFromPlaylist(index)
    }

    Dialog {
        id: propertiesDialog
        title: "歌曲属性"
        modal: true
        standardButtons: Dialog.Ok
        width: 500
        height: 400

        contentItem: Rectangle {
            color: "transparent"
            ScrollView {
                anchors.fill: parent
                anchors.margins: 10
                TextArea {
                    id: propertiesTextArea
                    readOnly: true
                    wrapMode: Text.Wrap
                    font.pixelSize: 12
                    color: "white"
                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }
        }

        background: Rectangle {
            color: "#2a2a2a"
            radius: 8
        }
    }

    FileDialog {
        id: fileDialog
        title: "Select Music Files"
        nameFilters: ["Music Files (*.mp3 *.wav *.flac *.ogg *.m4a)"]
        currentFolder: StandardPaths.standardLocations(StandardPaths.MusicLocation)[0]
        onAccepted: {
            for (let i = 0; i < selectedFiles.length; i++) {
                playerController.addSong(selectedFiles[i])
            }
        }
    }

    FolderDialog {
        id: folderDialog
        title: "Select Music Folder"
        currentFolder: StandardPaths.standardLocations(StandardPaths.MusicLocation)[0]
        onAccepted: playerController.addFolder(selectedFolder)
    }

    function formatTime(milliseconds) {
        if (!milliseconds || milliseconds <= 0) return "00:00"
        let seconds = Math.floor(milliseconds / 1000)
        let minutes = Math.floor(seconds / 60)
        seconds = seconds % 60
        return minutes.toString().padStart(2, '0') + ":" + seconds.toString().padStart(2, '0')
    }
}