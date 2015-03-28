import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.3
import org.ethereum.qml.SortFilterProxyModel 1.0

Rectangle
{
	function push(_level, _type, _content)
	{
		_content = _content.replace(/\n/g, " ")
		logsModel.insert(0, { "type": _type, "date": Qt.formatDateTime(new Date(), "hh:mm:ss dd.MM.yyyy"), "content": _content, "level": _level });
	}

	LogsPaneStyle {
		id: logStyle
	}

	id: root
	anchors.fill: parent
	radius: 5
	color: logStyle.generic.layout.backgroundColor
	border.color: logStyle.generic.layout.borderColor
	border.width: logStyle.generic.layout.borderWidth
	ColumnLayout {
		z: 2
		height: parent.height
		width: parent.width
		spacing: 0
		Row
		{
			id: rowAction
			Layout.preferredHeight: logStyle.generic.layout.headerHeight
			height: logStyle.generic.layout.headerHeight
			anchors.leftMargin: logStyle.generic.layout.leftMargin
			anchors.left: parent.left
			spacing: logStyle.generic.layout.headerButtonSpacing
			Button
			{
				height: logStyle.generic.layout.headerButtonHeight
				anchors.verticalCenter: parent.verticalCenter
				action: clearAction
				iconSource: "qrc:/qml/img/broom.png"
			}

			Action {
				id: clearAction
				enabled: logsModel.count > 0
				tooltip: qsTr("Clear")
				onTriggered: {
					logsModel.clear()
				}
			}

			Button
			{
				height: logStyle.generic.layout.headerButtonHeight
				anchors.verticalCenter: parent.verticalCenter
				action: copytoClipBoardAction
				iconSource: "qrc:/qml/img/copy.png"
			}

			Action {
				id: copytoClipBoardAction
				enabled: logsModel.count > 0
				tooltip: qsTr("Copy to Clipboard")
				onTriggered: {
					var content = "";
					for (var k = 0; k < logsModel.count; k++)
					{
						var log = logsModel.get(k);
						content += log.type + "\t" + log.level + "\t" + log.date + "\t" + log.content + "\n";
					}
					clipboard.text = content;
				}
			}

			Rectangle {
				anchors.verticalCenter: parent.verticalCenter
				width: 1;
				height: parent.height - 10
				color : "#808080"
			}

			ToolButton {
				id: javascriptButton
				checkable: true
				height: logStyle.generic.layout.headerButtonHeight
				anchors.verticalCenter: parent.verticalCenter
				checked: true
				onCheckedChanged: {
					proxyModel.toogleFilter("javascript")
				}
				tooltip: qsTr("JavaScript")
				style:
					ButtonStyle {
					label:
						Item {
						DefaultLabel {
							font.family: logStyle.generic.layout.logLabelFont
							font.pointSize: appStyle.absoluteSize(-3)
							color: logStyle.generic.layout.logLabelColor
							anchors.centerIn: parent
							text: qsTr("JavaScript")
						}
					}
				}
			}

			ToolButton {
				id: runButton
				checkable: true
				height: logStyle.generic.layout.headerButtonHeight
				anchors.verticalCenter: parent.verticalCenter
				checked: true
				onCheckedChanged: {
					proxyModel.toogleFilter("run")
				}
				tooltip: qsTr("Run")
				style:
					ButtonStyle {
					label:
						Item {
						DefaultLabel {
							font.family: logStyle.generic.layout.logLabelFont
							font.pointSize: appStyle.absoluteSize(-3)
							color: logStyle.generic.layout.logLabelColor
							anchors.centerIn: parent
							text: qsTr("Run")
						}
					}
				}
			}

			ToolButton {
				id: stateButton
				checkable: true
				height: logStyle.generic.layout.headerButtonHeight
				anchors.verticalCenter: parent.verticalCenter
				checked: true
				onCheckedChanged: {
					proxyModel.toogleFilter("state")
				}
				tooltip: qsTr("State")
				style:
					ButtonStyle {
					label:
						Item {
						DefaultLabel {
							font.family: logStyle.generic.layout.logLabelFont
							font.pointSize: appStyle.absoluteSize(-3)
							color: "#5391d8"
							anchors.centerIn: parent
							text: qsTr("State")
						}
					}
				}
			}

			ToolButton {
				id: compilationButton
				checkable: true
				height: logStyle.generic.layout.headerButtonHeight
				anchors.verticalCenter: parent.verticalCenter
				checked: false
				onCheckedChanged: {
					proxyModel.toogleFilter("compilation")
				}
				tooltip: qsTr("Compilation")
				style:
					ButtonStyle {
					label:
						Item {
						DefaultLabel {
							font.family: logStyle.generic.layout.logLabelFont
							font.pointSize: appStyle.absoluteSize(-3)
							color: "#5391d8"
							anchors.centerIn: parent
							text: qsTr("Compilation")
						}
					}
				}
			}

			DefaultTextField
			{
				id: searchBox
				height: logStyle.generic.layout.headerButtonHeight
				anchors.verticalCenter: parent.verticalCenter
				width: logStyle.generic.layout.headerInputWidth
				font.family: logStyle.generic.layout.logLabelFont
				font.pointSize: appStyle.absoluteSize(-3)
				font.italic: true
				onTextChanged: {
					proxyModel.search(text);
				}
			}
		}

		ListModel {
			id: logsModel
		}

		TableView {
			id: logsTable
			clip: true
			Layout.fillWidth: true
			Layout.preferredHeight: parent.height - rowAction.height
			headerVisible : false
			onDoubleClicked:
			{
				var log = logsModel.get(logsTable.currentRow);
				if (log)
					clipboard.text = (log.type + "\t" + log.level + "\t" + log.date + "\t" + log.content);
			}

			model: SortFilterProxyModel {
				id: proxyModel
				source: logsModel
				property var roles: ["-", "javascript", "run", "state"]

				Component.onCompleted: {
					filterType = regEx(proxyModel.roles);
				}

				function search(_value)
				{
					filterContent = _value;
				}

				function toogleFilter(_value)
				{
					var count = roles.length;
					for (var i in roles)
					{
						if (roles[i] === _value)
						{
							roles.splice(i, 1);
							break;
						}
					}
					if (count === roles.length)
						roles.push(_value);

					filterType = regEx(proxyModel.roles);
				}

				function regEx(_value)
				{
					return "(?:" + roles.join('|') + ")";
				}

				filterType: "(?:javascript|run|state)"
				filterContent: ""
				filterSyntax: SortFilterProxyModel.RegExp
				filterCaseSensitivity: Qt.CaseInsensitive
			}
			TableViewColumn
			{
				role: "date"
				title: qsTr("date")
				width: logStyle.generic.layout.dateWidth
				delegate: itemDelegate
			}
			TableViewColumn
			{
				role: "type"
				title: qsTr("type")
				width: logStyle.generic.layout.typeWidth
				delegate: itemDelegate
			}
			TableViewColumn
			{
				role: "content"
				title: qsTr("content")
				width: logStyle.generic.layout.contentWidth
				delegate: itemDelegate
			}

			rowDelegate: Item {
				Rectangle {
					width: logsTable.width - 4
					height: 17
					color: styleData.alternate ? "transparent" : logStyle.generic.layout.logAlternateColor
				}
			}
		}

		Component {
			id: itemDelegate
			DefaultLabel {
				text: styleData.value;
				font.family: logStyle.generic.layout.logLabelFont
				font.pointSize: appStyle.absoluteSize(-1)
				color: {
					if (proxyModel.get(styleData.row).level === "error")
						return "red";
					else if (proxyModel.get(styleData.row).level === "warning")
						return "orange";
					else
						return "#808080";
				}
			}
		}
	}
}
