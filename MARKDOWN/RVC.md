# Robotic Vacuum Cleaner (SVC System)
Example on requirements process.

- [Stakeholders](#stakeholders)

- [Context Diagram](#context-diagram)

- [Interfaces](#interfaces)

- [FR and NFR](#functional-and-non-functional-requirements)
  + [Functional Requirements](#functional-requirements)
  + [Non Functional Requirements](#non-functional-requirements)

- [Use cases](#use-case-diagram-and-use-cases)
  + [Use case diagram](#use-case-diagram)
  + [Use cases scenario](#use-cases)

- [System design](#system-design)

- [Deployment diagram](#deployment-diagram)


# Stakeholders
**Definition**: anything that have or is having an impact (or a effect) on system
            (or product or software) that we designed

| **Stakeholder name** | **Description** |
|:---------------  | :---------  |
| End user         | final user of the SVC |
| Marketing people | marketing strategy |
| Resellers        | Shops or supermarkets that are selling SVC |
| Developers       | Software engineers and computer scientists |
| Manteiners       | People assigned to reparation |
| Certification autority | People that will check all legal safety issues |
| Environment      | House or apartment room where SVC is going to operate |  

# Context diagram
**Definition**: link between Actors and system
- *Actor*: subset of stackeholders that is going to use our System

```plantuml
actor :End user: as A1
actor :Power Socket: as A2
actor :Environment: as A3
"SVC System" as (SYS)
A1--(SYS)
A2-->(SYS)
A3--(SYS)
```

# Interfaces
**Definition**: Physical device used by links defined in Context diagram

| **Actor** | **Physical Interface** |
|:--------- |:-----------------------|
| End user  | Switches [On,Off,Learn]|
| Power sock| Schuko standard cables |
| Obstacles | Infrared sensors       |

# Functional and non functional requirements
## Functional Requirements
**Definition**: What are the functions that our system should be capable off

| **ID**        | **Description** |
|:------------- |:----------------|
| FR1 | Clean the House|
| *FR1.1* | Start brush engine|
| *FR1.2* | Stop brush engine|
| FR2 | Learn the House, from power sock|
| *FR2.1* | Map a room|
| *FR2.2* | Map all obstacles|
| FR3 | Charge and Recharge|
| *FR3.1* | check and monitor battery level|
| *FR3.2* | charge battery when returning back "home"|
| *FR3.3* | recharge battery @threshold|
| FR4 | Do not harm people|
| FR5 | Move autonomously|
| *FR5.1* | recognise dynamic obstacles|
| *FR5.2* | recognise dynamic changes in room map|
| *FR5.3* | decide path|

## Non Functional requirements
**Definition**: Add some details on previoulsy defined FReqs (NFR and FR must be
consistent), describe *how* the system should perform a certain functionality.
**All NFR must be misurable**


| **ID**        | **Description** | **Referred to FR** |
|:------------- |:----------------|:-------------------|
| NFR1 | clean at least 100 sqr/mt every minute| FR1 |
| NFR2 | learn the house in less than 1 hour| FR2 |
| NFR3 | affidability > 99.99999% | FR4 |


# Use case diagram and use cases

## Use case diagram
**Definition**: diagram that describes what Actors need to do with the system, and so all interactions between Actors and Functional Requirements.
It's a more detailed context diagram.
In this diagram are missing all NFReq, btw they should be present..

```plantuml
actor :End User: as Primary
actor :Power Socket: as Power
actor :Environment: as Obstacles
"Robot Vacuum Cleaner" as (RVC)
"Clean the house" as (FRClean)
"Learn the house" as (FRLearn)
"Move in the house" as (FRMove)
"Charge and recharge" as (FRBattery)
"Do not harm people" as (FRSafety)
(RVC) .> (FRClean) :include
(RVC) .> (FRLearn) :include
(RVC) .> (FRMove) :include
(RVC) .> (FRBattery) :include
(RVC) .> (FRSafety) :include
Primary-->(FRClean)
Primary-->(FRLearn)
Power<--(FRBattery)
Obstacles<--(FRMove)
```

## Use cases
**Definition**: text-based description of set of scenarios describing what is going on when an Actors use a particular system functionality.
Here follow only one example, there should be at least one use case for each main functionality..

| **Actor involved:** | **End User** |
|:--------------------|:-------------|
|**Precondition:**    |a) Robot is *ON*|
|                     |b) Battery is fully charged|
|                     |c) Learning phase completed|
|**Postcondition:**   |a) All house has been cleaned|
|**Nominal scenario:**|a) End user pushes *START* button|
|                     |b) Robot starts cleaning from closest tile from the power station|
|                     |c) Repeats procedure until all tiles have been cleaned|
|                     |d) Robot returns to the power stations|
|**Variant scenario:**|a) ..|
|                     |b) ..|
|                     |c) After a while, the battery runs down the threshold, the robot must interrupt all current operations and return to the power station|
|                     |d) after the battery is fully recharged than the robot  must resume the cleaning from the interruption point|
|                     |e) Robot returns to the power station|

# System design
**Definition**: Describe all physical and software components that are part of the systems.


@startuml
object Robot
object Computer
object Software
object "Robot Vacuum Cleaner" as SVC
object Switch
object Wheel
object "Wheel sensor" as WS
object "Obstacle sensor" as OBS
object Battery
object "Battery sensor" as BS
object "Charging station" as CS
object "Power socket" as PSOC
Robot o-- Computer
Computer -- Software
Robot o-- OBS
Robot o-- "4" Wheel
Wheel o-- "0..1" WS
Robot o-- Battery
Battery o-- BS
Robot o-- "3" Switch : "on, off, start"
SVC o-- Robot
SVC o-- CS
CS o-- PSOC
@enduml

# Deployment Diagram
**Definition**: Shows the hardware-software configuration
*NODE*: Entity capable of processing
*ARTIFACT*: Source file, library, executable, table, db, ..

```plantuml
artifact "Control" {
file "Engine control"
file "Battery control"
file "Sensor control"
}
artifact "App" {
file "Cleaning and Learning Algorithms"
}
node "ECU"
node "CPU"
Control -- ECU
App -- CPU
ECU == CPU : "Can bus"
```
