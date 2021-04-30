# **Movie Shop**

A movie shop proposes movies for purchase or hiring. A catalogue lists the movies available.
The shop also offers subscription cards. Subscribers can purchase cards and upload on them a credit, using cash or a credit card.
Only subscribers are allowed hiring movies with their own card.
Credit is updated on the card during rent operations.
Both users and subscribers can buy a movie and their data are saved in the related order.
The shop must monitor the availability of movies and purchase them from distributors when needed.

# Conceptual Diagram

*OSS:* there's not a direct association between *Subscriber* and *Recharge* because
       it would be a redundant loop!
       Because when you have a *Recharge* transaction you are always able to know who
       is the subscriber, due to the fact that a card can be associated to only one
       subscriber.
       same for *Rental* transactions, that are always associated with a card.

  ![Conceptual UML](http://www.plantuml.com/plantuml/png/RLF1QW8n4BtlLmnx4KfTwbMAIBUN7cgXBRrdDwa6Oh8a4qNentVYJZIo7iINl3SpxoMRTK3XCUvDrHiH0dpjtC2m5IYCsqR5wpTxK1QTF_7wtHrqvbvLwBqUYAsgr0BcywB-Wj9s_L0NSbY2qG43h79TCUU2k6uSIINQzYPAbQh6BU8B2spgmqlb6NzxOOFeKJkRayPXC9e4Pnay_r6FKfNjq5pkb2lANIwV1gkiGmNroEe0dGYw5yQSG9mJW_k5sO_s68KPSuNP8mG76cU1D7Yr0cJNzLgWad3Kk2kcXAOc5ZOBjj4q2MyM2KmFv2MUAlfDil8XfW14a8BrRGpezfIHGOvPIEhMAwaHMk5bFT7TikMAkAUcMTIil7i_NVBVqVWC-PgklbYQ6ZByLFrE-AsgCfY6RLbeKPXg_9kAokk_RoMJQJWimHrj-XpJAXzaja2iPoYXe-FdgQpB7QIpQhpVrQs0NzfQMKaFzHy0)


