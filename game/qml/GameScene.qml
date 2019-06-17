import Felgo 3.0
import QtQuick 2.0
import "entities"
import "levels"

Scene {
  id: gameScene
  // the "logical size" - the scene content is auto-scaled to match the GameWindow size
  width: 299
  height: 224
  gridSize: 32

  property int offsetBeforeScrollingStarts: 100
  property alias psb: psb

  EntityManager {
    id: entityManager
  }

  // the whole screen is filled with an incredibly beautiful blue ...
  Rectangle {
    anchors.fill: gameScene.gameWindowAnchorItem
    color: "#74d6f7"
  }

  // ... followed by 2 parallax layers with trees and grass
//  ParallaxScrollingBackground {
//    sourceImage: "../assets/background/layer2.png"
//    anchors.bottom: gameScene.gameWindowAnchorItem.bottom
//    anchors.horizontalCenter: gameScene.gameWindowAnchorItem.horizontalCenter
//    // we move the parallax layers at the same speed as the player
//    movementVelocity: player.x > offsetBeforeScrollingStarts ? Qt.point(-player.horizontalVelocity,0) : Qt.point(0,0)
//    // the speed then gets multiplied by this ratio to create the parallax effect
//    ratio: Qt.point(0.3,0)
//  }
  ParallaxScrollingBackground {
      id: psb
    sourceImage: "../assets/background/bg.jpg"
    anchors.bottom: gameScene.gameWindowAnchorItem.bottom
    anchors.horizontalCenter: gameScene.gameWindowAnchorItem.horizontalCenter
    movementVelocity: player.x > offsetBeforeScrollingStarts ? Qt.point(-player.horizontalVelocity,0) : Qt.point(0,0)
    ratio: Qt.point(0,0)
  }

  // this is the moving item containing the level and player
  Item {
    id: viewPort
    height: level.height
    width: level.width
    anchors.bottom: gameScene.gameWindowAnchorItem.bottom
    x: player.x > offsetBeforeScrollingStarts ? offsetBeforeScrollingStarts-player.x : 0

    PhysicsWorld {
      id: physicsWorld
      gravity: Qt.point(0, 25)//人物能够跳的高度，数值越大跳得越矮
      debugDrawVisible: true // enable this for physics debugging
      z: 1000

      onPreSolve: {
        //this is called before the Box2DWorld handles contact events
        var entityA = contact.fixtureA.getBody().target
        var entityB = contact.fixtureB.getBody().target
        if(entityB.entityType === "platform" && entityA.entityType === "player" &&
            entityA.y + entityA.height > entityB.y) {
          //by setting enabled to false, they can be filtered out completely
          //-> disable cloud platform collisions when the player is below the platform
          contact.enabled = false
        }
      }
    }

    // you could load your levels Dynamically with a Loader component here
    Level1 {
      id: level
    }

    Player {
      id: player
      x: 20
      y: 100
    }

    ResetSensor {
      width: player.width
      height: 10
      x: player.x
      anchors.bottom: viewPort.bottom
      // if the player collides with the reset sensor, he goes back to the start
      onContact: {
//        player.x = 20
//            ratio : Qt.point(0,0)
        psb.running = false
          player.x = playerx-30
        player.y = 100
          psb.running = true
      }
      // this is just for you to see how the sensor moves, in your real game, you should position it lower, outside of the visible area
      Rectangle {
        anchors.fill: parent
        color: "yellow"
        opacity: 0.5
      }
    }
  }

  Rectangle {
    // you should hide those input controls on desktops, not only because they are really ugly in this demo, but because you can move the player with the arrow keys there
    //visible: !system.desktopPlatform
    //enabled: visible
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: 50
    width: 150
    color: "blue"
    opacity: 0.4

    Rectangle {
      anchors.centerIn: parent
      width: 1
      height: parent.height
      color: "white"
    }
    MultiPointTouchArea {
      anchors.fill: parent
      onPressed: {
        if(touchPoints[0].x < width/2)
          controller.xAxis = -1
        else
          controller.xAxis = 1
      }
      onUpdated: {
        if(touchPoints[0].x < width/2)
          controller.xAxis = -1
        else
          controller.xAxis = 1
      }
      onReleased: controller.xAxis = 0
    }
  }

  Rectangle {
    // same as the above input control
    //visible: !system.desktopPlatform
    //enabled: visible
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    height: 100
    width: 100
    color: "green"
    opacity: 0.4

    Text {
      anchors.centerIn: parent
      text: "jump"
      color: "white"
      font.pixelSize: 9
    }
    MouseArea {
      anchors.fill: parent
      onPressed: player.jump()
    }
  }

  // on desktops, you can move the player with the arrow keys, on mobiles we are using our custom inputs above to modify the controller axis values. With this approach, we only need one actual logic for the movement, always referring to the axis values of the controller
  Keys.forwardTo: controller
  TwoAxisController {
    id: controller
    onInputActionPressed: {
      console.debug("key pressed actionName " + actionName)
      if(actionName == "up") {
        player.jump()
      }
    }
  }
}

