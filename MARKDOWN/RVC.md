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

![Context](http://www.plantuml.com/plantuml/png/SoWkIImgAStDuKfCBialKh1opKjHA2rEBR9II2nMS3I42GVabwSMAGJd9sUdba2aZ10woZABylDoK_EWCiPSIi5XpWh1bSKbgRbA826DuCXWJIv7GrrTACj8LzSEoZI62JgavgK07G80)

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

![Use Case](http://www.plantuml.com/plantuml/svg/RP71JiCm38RlVGgh9pYK1wZGD37W16BgnEvUQcX54a-ECxItfscXuP1Z_kzFzCNU1aNHw6o5HbcWVV8zl0UI5Z30NaQ7SlrZU_ucWGERBzA5fo3Vl8p2tf5VuDifA1fBeQexFh724KsC3dQMq9FKgNFJ7NUtLJr7e0F1m37GWfwxEPxm2w4KS8eJVkKBmLWe991U7r0-2T3t86JIOMqye2h9TIezCdXMcAY3C_7Phfq3Vf1EbTaLxZRP3DhH6njxocpLAhDaL4HPfK2pH8Q_gscQJHvKpl9qvXNTDyt_pwwRMV9bJ5loVNJs1m00)


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

![System Design](http://www.plantuml.com/plantuml/svg/JP7DReCm48JlFCNAvoHgrPvwYk878Agbv6pSvQS5RsKlGdtxMWisN91dvrk9cRr6je7dQQoe-KR7y4aDSHQQfj-PCMHjgEN51inQ2GqFw-Pv0ZsYzHWKs0ZceSlICh3hithsY6FP5mKHVQHrxscALpUHhHlnQDUtujyiCuQ_Wc_wIE-mqhqDtU0xY6nv82--tlqxBHWWalj15kzkQbsjyUXytfl83qZ3KaVXv0TtfTxL5bY-w-pbSdbDumDNikGCCZi2warjFS87AF8deBOzWHnFLQbieOGlAgNJHbwIvOh-Aztv7m00)

# Deployment Diagram
**Definition**: Shows the hardware-software configuration
*NODE*: Entity capable of processing
*ARTIFACT*: Source file, library, executable, table, db, ..

![deployment diagram](http://www.plantuml.com/plantuml/svg/NOx12i8m38RlVOhG-rv066mMRnu4yG7Ybir2buukFOZuxgPIc7Zgd-zllwRR19Fa9HWz_8I3W7MH9SLWuMKc7mZiYMVF14FbbHvHXDBp7r-9jvXs-lunz-kwMrqWPCyp88zm9apVeGzpJ5uUorQUSXpB_-vcQtGNZNL1Q1hGogYrHAsCZj2s9S91BoF3FQke8nxp4Zu0)
