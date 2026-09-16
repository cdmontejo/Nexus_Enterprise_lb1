pragma Singleton
import QtQuick 2.15

QtObject {
    id: theme

    property string activeTheme: "dark"

    readonly property color bgBase:     activeTheme === "dark" ? "#070E1C" : "#EEF2F7"
    readonly property color bgSurface:  activeTheme === "dark" ? "#10192A" : "#FFFFFF"
    readonly property color bgElevated: activeTheme === "dark" ? "#1A263A" : "#E2E8F0"
    readonly property color bgInput:    activeTheme === "dark" ? "#0C1422" : "#F8FAFC"
    readonly property color bgSlate:    activeTheme === "dark" ? "#2B3A4F" : "#CBD5E1"

    property color accentPrimary: "#1FA8FF"
    readonly property color accentPrimaryHover:   Qt.lighter(accentPrimary, 1.18)
    readonly property color accentPrimaryPressed: Qt.darker(accentPrimary, 1.22)
    readonly property color accentPurple:  "#7C3AED"
    readonly property color accentSuccess: "#10B981"
    readonly property color accentDanger:  "#EF4444"

    readonly property color textPrimary:   activeTheme === "dark" ? "#F0F6FF" : "#0F172A"
    readonly property color textSecondary: activeTheme === "dark" ? "#8DA4BF" : "#64748B"
    readonly property color textDisabled:  activeTheme === "dark" ? "#56697D" : "#94A3B8"
    readonly property color textOnAccent:  "#FFFFFF"

    readonly property color borderSubtle: activeTheme === "dark" ? "#1E3048" : "#E2E8F0"
    readonly property color borderFocus:  accentPrimary

    readonly property color statusOk:    accentSuccess
    readonly property color statusWarn:  "#F59E0B"
    readonly property color statusError: accentDanger
    readonly property color statusInfo:  accentPrimary

    readonly property int radiusSm: 8
    readonly property int radiusMd: 12
    readonly property int radiusLg: 18
    readonly property int radiusXl: 24

    readonly property int animFast: 140
    readonly property int animBase: 260
    readonly property int animSlow: 500

    readonly property color glassFill:      activeTheme === "dark"
                                            ? Qt.rgba(0.06, 0.12, 0.22, 0.72)
                                            : Qt.rgba(1.0,  1.0,  1.0,  0.68)
    readonly property color glassBorder:    activeTheme === "dark"
                                            ? Qt.rgba(1.0, 1.0, 1.0, 0.16)
                                            : Qt.rgba(1.0, 1.0, 1.0, 0.85)
    readonly property color glassSheen:     activeTheme === "dark"
                                            ? Qt.rgba(1.0, 1.0, 1.0, 0.08)
                                            : Qt.rgba(1.0, 1.0, 1.0, 0.45)
    readonly property color glassHighlight: activeTheme === "dark"
                                            ? Qt.rgba(0.12, 0.66, 1.0, 0.14)
                                            : Qt.rgba(0.12, 0.66, 1.0, 0.10)

    readonly property color orb1Color: activeTheme === "dark" ? Qt.rgba(0.12, 0.50, 1.0, 0.22) : Qt.rgba(0.12, 0.50, 1.0, 0.14)
    readonly property color orb2Color: activeTheme === "dark" ? Qt.rgba(0.55, 0.15, 0.90, 0.18) : Qt.rgba(0.55, 0.15, 0.90, 0.12)
    readonly property color orb3Color: activeTheme === "dark" ? Qt.rgba(0.06, 0.75, 0.65, 0.14) : Qt.rgba(0.06, 0.75, 0.65, 0.10)
    readonly property color orb4Color: activeTheme === "dark" ? Qt.rgba(0.15, 0.60, 1.0, 0.12) : Qt.rgba(0.15, 0.60, 1.0, 0.08)
}
