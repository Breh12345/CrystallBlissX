import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Item {
    id: screenRoot
    width: 1280
    height: 720

    // 1. BACKGROUND LAYER
    Rectangle { anchors.fill: parent; color: "#1a1a1a" }
    Background {
        anchors.fill: parent
        source: "/usr/share/sddm/themes/elarun/images/background.png"
        fillMode: Image.PreserveAspectCrop
    }

    // --- 2. THE TOP BAR ---
    Rectangle {
        id: topBar
        width: parent.width
        height: 32
        anchors.top: parent.top
        color: "#AA000000"
        z: 600

        Row {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            spacing: 20

            Item {
                id: sessionSelector
                width: 180
                height: parent.height

                Text {
                    anchors.centerIn: parent
                    color: "#FFFFFF"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    text: (sessionModel.data(sessionModel.index(root.sessionIndex, 0), Qt.DisplayRole) || "Select Session") + "  ▼"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.menuOpen = !root.menuOpen
                }

                Rectangle {
                    id: dropdownMenu
                    width: 200
                    height: root.menuOpen ? Math.min(sessionModel.rowCount() * 35, 200) : 0
                    anchors.top: parent.bottom
                    anchors.topMargin: 2
                    color: "#1a1a1a"
                    border.color: "#44FFFFFF"
                    radius: 6
                    clip: true
                    visible: height > 0

                    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutQuart } }

                    ListView {
                        anchors.fill: parent
                        model: sessionModel
                        delegate: Rectangle {
                            width: dropdownMenu.width; height: 35
                            color: itemMouse.containsMouse ? "#33FFFFFF" : "transparent"
                            Text {
                                anchors.left: parent.left; anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#FFFFFF"; font.pixelSize: 11
                                text: model.name || modelData.name
                            }
                            MouseArea {
                                id: itemMouse; anchors.fill: parent; hoverEnabled: true
                                onClicked: {
                                    root.sessionIndex = index
                                    root.menuOpen = false
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 1; width: 1; anchors.horizontalCenter: parent.horizontalCenter }

            Text {
                id: dateTime
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: "#FFFFFF"; font.pixelSize: 12; font.weight: Font.Medium
            }
        }
    }

    // 3. THE FIXED 720p CONTAINER
    Rectangle {
        id: root
        width: 1280
        height: 720
        anchors.centerIn: parent
        color: "transparent"

        property int sessionIndex: sessionModel.lastSessionIndex
        property string selectedUser: userModel.lastUser
        property bool menuOpen: false

        // Click shield for menu
        MouseArea {
            anchors.fill: parent
            z: 500
            visible: root.menuOpen
            onClicked: root.menuOpen = false
        }

        // --- USER DELEGATE ---
        Component {
            id: userDelegateItem
            Column {
                spacing: 10
                width: 130
                property string d_name: modelData ? modelData.name : ""
                property int d_index: itemIndex

                Rectangle {
                    width: 130; height: 130
                    radius: 65
                    color: "#44000000"
                    border.color: "white"
                    border.width: (root.selectedUser === d_name) ? 3 : 0
                    clip: true
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        anchors.fill: parent
                        source: d_name ? "images/users/" + d_name + ".png" : "images/default_avatar.png"
                        fillMode: Image.PreserveAspectCrop
                        onStatusChanged: if (status === Image.Error) source = "images/default_avatar.png"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedUser = d_name            // Update data immediately
                            featuredView.currentIndex = d_index   // Move view immediately
                            if (root.state === "grid") root.state = ""
                                root.menuOpen = false
                                passwordField.text = ""               // Clear for new user
                                passwordField.forceActiveFocus()
                        }
                    }
                }
                Text { text: d_name; color: "#FFFFFF"; font.pixelSize: 18; anchors.horizontalCenter: parent.horizontalCenter }
            }
        }

        Image { id: mainPanel; source: "images/rectangle.png"; anchors.fill: parent; opacity: 0.85 }

        Column {
            anchors.fill: parent
            anchors.topMargin: 80
            spacing: 25

            Image {
                source: "images/apple_logo.png"
                width: 100; height: 100
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "CrystalBliss X"; font.pixelSize: 26; font.bold: true
                color: "#FFFFFF"; anchors.horizontalCenter: parent.horizontalCenter
            }

            // USER AREA
            Item {
                id: userArea
                width: parent.width; height: 300
                Row {
                    anchors.centerIn: parent; spacing: 40; visible: root.state !== "grid"
                    ImageButton { source: "images/arrow_left.png"; onClicked: featuredView.decrementCurrentIndex() }
                    Item {
                        width: 650; height: 300
                        PathView {
                            id: featuredView
                            anchors.fill: parent; model: userModel; pathItemCount: 3
                            preferredHighlightBegin: 0.5; preferredHighlightEnd: 0.5
                            highlightMoveDuration: 600; interactive: false
                            path: Path {
                                startX: 0; startY: 150
                                PathAttribute { name: "itemScale"; value: 0.6 }
                                PathLine { x: 325; y: 150 }
                                PathAttribute { name: "itemScale"; value: 1.2 }
                                PathLine { x: 650; y: 150 }
                                PathAttribute { name: "itemScale"; value: 0.6 }
                            }
                            delegate: Item {
                                width: 160; height: 250; scale: PathView.itemScale
                                Loader {
                                    anchors.centerIn: parent
                                    sourceComponent: userDelegateItem
                                    property var modelData: model
                                    property int itemIndex: index
                                }
                            }
                            onCurrentIndexChanged: {
                                var name = userModel.data(userModel.index(currentIndex, 0), Qt.DisplayRole)
                                if (name) root.selectedUser = name
                            }
                        }
                    }
                    ImageButton { source: "images/arrow_right.png"; onClicked: featuredView.incrementCurrentIndex() }
                }

                GridView {
                    id: fullGridView
                    anchors.fill: parent; cellWidth: 180; cellHeight: 200
                    model: userModel; visible: root.state === "grid"
                    delegate: Item {
                        width: 180; height: 200
                        Loader { sourceComponent: userDelegateItem; property var modelData: model; property int itemIndex: index }
                    }
                }
            }

            // LOGIN SECTION
            Column {
                spacing: 15; anchors.horizontalCenter: parent.horizontalCenter; visible: root.state !== "grid"
                TextField {
                    id: passwordField
                    width: 260; height: 42
                    echoMode: TextInput.Password; placeholderText: "Password for " + root.selectedUser
                    color: "#FFFFFF"
                    font.pixelSize: 14; horizontalAlignment: TextInput.AlignHCenter
                    background: Rectangle { radius: 10; color: "#33000000"; border.color: "#44FFFFFF"; border.width: 1 }
                    Keys.onPressed: { if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) sddm.login(root.selectedUser, passwordField.text, root.sessionIndex) }
                }

                ImageButton {
                    source: "images/login_normal.png"
                    onClicked: sddm.login(root.selectedUser, passwordField.text, root.sessionIndex)
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Row {
                spacing: 25; anchors.horizontalCenter: parent.horizontalCenter
                ImageButton { source: "images/users_icon.png"; onClicked: root.state = (root.state === "grid" ? "" : "grid") }
                ImageButton { source: "images/system_shutdown.png"; onClicked: sddm.powerOff() }
                ImageButton { source: "images/system_reboot.png"; onClicked: sddm.reboot() }
            }
        }
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: dateTime.text = Qt.formatDateTime(new Date(), "ddd d MMM, HH:mm")
    }

    Connections { target: sddm; onLoginFailed: { passwordField.text = ""; passwordField.forceActiveFocus() } }

    Component.onCompleted: {
        passwordField.forceActiveFocus()
        root.sessionIndex = sessionModel.lastSessionIndex
    }
}
