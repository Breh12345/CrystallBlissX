
import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1280
    height: 720
    color: "#000000"

    property int sessionIndex: 0
    property string defaultUserIcon: Qt.resolvedUrl("images/default_avatar.png")

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginSucceeded() {}
        function onInformationMessage(message) {}
        function onLoginFailed() { passwordField.text = "" }
    }

    Background {
        anchors.fill: parent
        source: Qt.resolvedUrl(config.background)
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            var defaultBG = Qt.resolvedUrl(config.defaultBackground)
            if (status == Image.Error && source != defaultBG) {
                source = defaultBG
            }
        }
    }

    // Main panel
    Rectangle {
        id: panel
        width: 1280
        height: 720
        color: "#00000000"
        anchors.centerIn: parent

        Image { anchors.fill: parent; source: Qt.resolvedUrl("images/rectangle.png") }
        Image { anchors.fill: parent; source: Qt.resolvedUrl("images/rectangle_overlay.png"); opacity: 0.1 }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Image {
                source: Qt.resolvedUrl("images/apple_logo.png")
                width: 100; height: 100
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "CrystalBliss X"
                font.pixelSize: 18
                font.bold: true
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // User display (icon above username)
            Column {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 150
                    height: 150
                    radius: width / 2
                    clip: true
                    color: "#222222"

                    Image {
                        anchors.fill: parent
                        source: Qt.resolvedUrl("images/users/" + userModel.lastUser + ".png")
                        ? Qt.resolvedUrl("images/users/" + userModel.lastUser + ".png")
                        : defaultUserIcon
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Text {
                    text: userModel.lastUser
                    color: "#FFFFFF"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // Password input
            Row {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                TextField {
                    id: passwordField
                    width: 150; height: 30
                    font.pixelSize: 14
                    color: "#FFFFFF"
                    echoMode: TextInput.Password
                    KeyNavigation.tab: loginButton

                    background: Rectangle {
                        radius: 6
                        color: "#222222"
                        border.color: "#555555"
                        border.width: 1
                    }

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(userModel.lastUser, passwordField.text, sessionIndex)
                            event.accepted = true
                        }
                    }
                }
            }

            // Login button
            ImageButton {
                id: loginButton
                anchors.horizontalCenter: parent.horizontalCenter
                source: Qt.resolvedUrl("images/login_normal.png")
                onClicked: sddm.login(userModel.lastUser, passwordField.text, sessionIndex)
                KeyNavigation.backtab: passwordField
                KeyNavigation.tab: session
            }

            // Action buttons row
            Row {
                id: buttonRow
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                ImageButton { id: systemButton; source: Qt.resolvedUrl("images/system_shutdown.png"); onClicked: sddm.powerOff(); KeyNavigation.tab: rebootButton }
                ImageButton { id: rebootButton; source: Qt.resolvedUrl("images/system_reboot.png"); onClicked: sddm.reboot(); KeyNavigation.backtab: systemButton; KeyNavigation.tab: suspendButton }
                ImageButton { id: suspendButton; visible: sddm.canSuspend; source: Qt.resolvedUrl("images/system_suspend.png"); onClicked: sddm.suspend(); KeyNavigation.backtab: rebootButton; KeyNavigation.tab: hibernateButton }
                ImageButton { id: hibernateButton; visible: sddm.canHibernate; source: Qt.resolvedUrl("images/system_hibernate.png"); onClicked: sddm.hibernate(); KeyNavigation.backtab: suspendButton; KeyNavigation.tab: session }
            }

            // Date/Time
            Text {
                id: dateTime
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#0b678c"
                font.pixelSize: 12
                font.bold: true
            }

            Timer {
                id: time
                interval: 100
                running: true
                repeat: true
                onTriggered: dateTime.text = Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy HH:mm AP")
            }
        }
    }
}
    // Top action bar with icon-ready ComboBox
