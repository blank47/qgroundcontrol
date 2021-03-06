/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0

// Editor for Fixed Wing Landing Pattern complex mission item
Rectangle {
    id:         _root
    height:     visible ? ((editorColumn.visible ? editorColumn.height : editorColumnNeedLandingPoint.height) + (_margin * 2)) : 0
    width:      availableWidth
    color:      qgcPal.windowShadeDark
    radius:     _radius

    // The following properties must be available up the hierarchy chain
    //property real   availableWidth    ///< Width for control
    //property var    missionItem       ///< Mission Item for editor

    property var    _masterControler:               masterController
    property var    _missionController:             _masterControler.missionController
    property var    _missionVehicle:                _masterControler.controllerVehicle
    property real   _margin:                    ScreenTools.defaultFontPixelWidth / 2
    property real   _spacer:                    ScreenTools.defaultFontPixelWidth / 2
    property string _setToVehicleHeadingStr:    qsTr("Set to vehicle heading")
    property string _setToVehicleLocationStr:   qsTr("Set to vehicle location")
    property bool   _showCameraSection:         !_missionVehicle.apmFirmware
    property int    _altitudeMode:              missionItem.altitudesAreRelative ? QGroundControl.AltitudeModeRelative : QGroundControl.AltitudeModeAbsolute


    Column {
        id:                 editorColumn
        anchors.margins:    _margin
        anchors.left:       parent.left
        anchors.right:      parent.right
        spacing:            _margin
        visible:            !editorColumnNeedLandingPoint.visible

        SectionHeader {
            id:             loiterPointSection
            anchors.left:   parent.left
            anchors.right:  parent.right
            text:           qsTr("Loiter point")
        }

        Column {
            anchors.left:       parent.left
            anchors.right:      parent.right
            spacing:            _margin
            visible:            loiterPointSection.checked

            Item { width: 1; height: _spacer }

            GridLayout {
                anchors.left:    parent.left
                anchors.right:   parent.right
                columns:         2

                QGCLabel { text: qsTr("Altitude") }

                AltitudeFactTextField {
                    Layout.fillWidth:   true
                    fact:               missionItem.loiterAltitude
                    altitudeMode:       _altitudeMode
                }

                QGCLabel { text: qsTr("Radius") }

                FactTextField {
                    Layout.fillWidth:   true
                    fact:               missionItem.loiterRadius
                }
            }

            Item { width: 1; height: _spacer }

            QGCCheckBox {
                text:           qsTr("Loiter clockwise")
                checked:        missionItem.loiterClockwise
                onClicked:      missionItem.loiterClockwise = checked
            }

            QGCButton {
                text:       _setToVehicleHeadingStr
                visible:    activeVehicle
                onClicked:  missionItem.landingHeading.rawValue = activeVehicle.heading.rawValue
            }
        }

        SectionHeader {
            id:             landingPointSection
            anchors.left:   parent.left
            anchors.right:  parent.right
            text:           qsTr("Landing point")
        }

        Column {
            anchors.left:       parent.left
            anchors.right:      parent.right
            spacing:            _margin
            visible:            landingPointSection.checked

            Item { width: 1; height: _spacer }

            GridLayout {
                anchors.left:    parent.left
                anchors.right:   parent.right
                columns:         2

                QGCLabel { text: qsTr("Heading") }

                FactTextField {
                    Layout.fillWidth:   true
                    fact:               missionItem.landingHeading
                }

                QGCLabel { text: qsTr("Altitude") }

                AltitudeFactTextField {
                    Layout.fillWidth:   true
                    fact:               missionItem.landingAltitude
                    altitudeMode:       _altitudeMode
                }

                QGCLabel { text: qsTr("Landing Dist") }

                FactTextField {
                    fact:               missionItem.landingDistance
                    Layout.fillWidth:   true
                }

                QGCButton {
                    text:               _setToVehicleLocationStr
                    visible:            activeVehicle
                    Layout.columnSpan:  2
                    onClicked:          missionItem.landingCoordinate = activeVehicle.coordinate
                }
            }
        }

        Item { width: 1; height: _spacer }

        QGCCheckBox {
            anchors.right:  parent.right
            text:           qsTr("Altitudes relative to launch")
            checked:        missionItem.altitudesAreRelative
            visible:        QGroundControl.corePlugin.options.showMissionAbsoluteAltitude || !missionItem.altitudesAreRelative
            onClicked:      missionItem.altitudesAreRelative = checked
        }

        SectionHeader {
            id:             cameraSection
            anchors.left:   parent.left
            anchors.right:  parent.right
            text:           qsTr("Camera")
            visible:        _showCameraSection
        }

        Column {
            anchors.left:       parent.left
            anchors.right:      parent.right
            spacing:            _margin
            visible:            _showCameraSection && cameraSection.checked

            Item { width: 1; height: _spacer }

            FactCheckBox {
                text:       _stopTakingPhotos.shortDescription
                fact:       _stopTakingPhotos

                property Fact _stopTakingPhotos: missionItem.stopTakingPhotos
            }

            FactCheckBox {
                text:       _stopTakingVideo.shortDescription
                fact:       _stopTakingVideo

                property Fact _stopTakingVideo: missionItem.stopTakingVideo
            }
        }

        Column {
            anchors.left:       parent.left
            anchors.right:      parent.right
            spacing:            0

            QGCLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                wrapMode:               Text.WordWrap
                color:                  qgcPal.warningText
                font.pointSize:         ScreenTools.smallFontPointSize
                text:                   qsTr("* Actual flight path will vary.")
            }

            QGCLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                wrapMode:               Text.WordWrap
                color:                  qgcPal.warningText
                font.pointSize:         ScreenTools.smallFontPointSize
                text:                   qsTr("* Avoid tailwind from loiter to land.")
            }
        }
    }

    Column {
        id:                 editorColumnNeedLandingPoint
        anchors.margins:    _margin
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        visible:            !missionItem.landingCoordSet || missionItem.wizardMode
        spacing:            ScreenTools.defaultFontPixelHeight

        Column {
            id:             landingCoordColumn
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        ScreenTools.defaultFontPixelHeight
            visible:        !missionItem.landingCoordSet

            QGCLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                wrapMode:               Text.WordWrap
                horizontalAlignment:    Text.AlignHCenter
                text:                   qsTr("Click in map to set landing point.")
            }

            QGCLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                horizontalAlignment:    Text.AlignHCenter
                text:                   qsTr("- or -")
                visible:                activeVehicle
            }

            QGCButton {
                anchors.horizontalCenter:   parent.horizontalCenter
                text:                       _setToVehicleLocationStr
                visible:                    activeVehicle

                onClicked: {
                    missionItem.landingCoordinate = activeVehicle.coordinate
                    missionItem.landingHeading.rawValue = activeVehicle.heading.rawValue
                }
            }
        }

        ColumnLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        ScreenTools.defaultFontPixelHeight
            visible:        !landingCoordColumn.visible

            onVisibleChanged: {
                if (visible) {
                    console.log(missionItem.landingDistance.rawValue)
                }
            }

            QGCLabel {
                Layout.fillWidth:   true
                wrapMode:           Text.WordWrap
                text:               qsTr("Drag the loiter point to adjust landing direction for wind and obstacles as well as distance to land point.")
            }

            QGCButton {
                text:               qsTr("Done")
                Layout.fillWidth:   true
                onClicked: {
                    missionItem.wizardMode = false
                    missionItem.landingDragAngleOnly = false
                    // Trial of no auto select next item
                    //editorRoot.selectNextNotReadyItem()
                }
            }
        }
    }
}
