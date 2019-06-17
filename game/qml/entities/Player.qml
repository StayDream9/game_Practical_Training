import Felgo 3.0
import QtQuick 2.0

EntityBase {
    id: player
    entityType: "player"
    width: 25
    height: 25

    // add some aliases for easier access to those properties from outside
    property alias collider: collider
    property alias horizontalVelocity: collider.linearVelocity.x

    // the contacts property is used to determine if the player is in touch with any solid objects (like ground or platform), because in this case the player is walking, which enables the ability to jump. contacts > 0 --> walking state
    property int contacts: 0
    // property binding to determine the state of the player like described above
    state: contacts > 0 ? "walking" : "jumping"
    onStateChanged: console.debug("player.state " + state)

    // here you could use a SpriteSquenceVPlay to animate your player
    MultiResolutionImage {
        width:25
        height: 25
        source: "../../assets/player/stand.bmp"
    }

    //控制人物左右移动
    BoxCollider {
        id: collider
        height: parent.height
        width: 30
        anchors.horizontalCenter: parent.horizontalCenter
        // this collider must be dynamic because we are moving it by applying forces and impulses
        bodyType: Body.Dynamic // this is the default value but I wanted to mention it ;)
        fixedRotation: true // we are running, not rolling...
        bullet: true // for super accurate collision detection, use this sparingly, because it's quite performance greedy
        sleepingAllowed: false
        // apply the horizontal value of the TwoAxisController as force to move the player left and right
        force: Qt.point(controller.xAxis*170*32,0)
        // limit the horizontal velocity
        onLinearVelocityChanged: {
          if(linearVelocity.x > 170) linearVelocity.x = 170
          if(linearVelocity.x < -170) linearVelocity.x = -170
        }
    }

    // this timer is used to slow down the players horizontal movement. the linearDamping property of the collider works quite similar, but also in vertical direction, which we don't want to be slowed
    Timer {
    id: updateTimer
    // set this interval as high as possible to improve performance, but as low as needed so it still looks good
    interval: 60
    running: true
    repeat: true
    onTriggered: {
      var xAxis = controller.xAxis;
      // if xAxis is 0 (no movement command) we slow the player down until he stops
      if(xAxis == 0) {
        if(Math.abs(player.horizontalVelocity) > 10) player.horizontalVelocity /= 1.5
        else player.horizontalVelocity = 0
      }
    }
    }

    Component {
      id: projectile

      EntityBase {
        entityType: "projectile"

        MultiResolutionImage {
          id: monsterImage
          source: "../../assets/player/bullet.bmp"
        }

        // these values can then be set when a new projectile is created in the MouseArea below
        property point destination
        property int moveDuration

        PropertyAnimation on x {
          from: player.x
          to: destination.x
          duration: moveDuration
        }

        PropertyAnimation on y {
          from: player.y
          to: destination.y
          duration: moveDuration
        }

        BoxCollider {
          anchors.fill: monsterImage
          collisionTestingOnlyMode: true
        }
      }// EntityBase
    }// Component

    //射击
    Item{
        focus: true
        Keys.onPressed: {
            if(event.key === Qt.Key_Space){
                event.accepted = true;
                console.debug("pressed")
//                var offset = Qt.point(150,50);

                // Bail out if we are shooting down or backwards
//                if(offset.x <= 0)
//                  return;

                // Determine where we wish to shoot the projectile to
                var realX = scene.gameWindowAnchorItem.width
//                var ratio = offset.y / offset.x
                var realY = realX + player.y
                var destination = Qt.point(realX, realY)

                // Determine the length of how far we're shooting
                var offReal = Qt.point(realX - player.x, realY - player.y)
                var length = Math.sqrt(offReal.x*offReal.x + offReal.y*offReal.y)
                var velocity = 480 // speed of the projectile should be 480pt per second
                var realMoveDuration = length / velocity * 1000 // multiply by 1000 because duration of projectile is in milliseconds

                entityManager.createEntityFromComponentWithProperties(projectile, {"destination": destination, "moveDuration": realMoveDuration})

//                projectileCreationSound.play()
            }
        }
    }

    function jump() {
    console.debug("jump requested at player.state " + state)
    if(player.state == "walking") {
      console.debug("do the jump")
      // for the jump, we simply set the upwards velocity of the collider
      collider.linearVelocity.y = -420
    }
    }

    //  function second_jump() {
    //      if()
    //  }
}

