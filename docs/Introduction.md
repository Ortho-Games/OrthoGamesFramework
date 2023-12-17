# Introduction

Orthogonal Games Framework is a game framework based on the ECS system Stew and makes heavy use of the Buffet Bundle Toolchain provided and maintained by Data Oriented House.

This project serves an example project meant to showcase the usage and guide for different patterns required to use the system for effective game development.

# Overview

Modules

Loaders

- Provides basic boot for both server & client scripts. Each script implements a descendants module require and the functionality for each schedules start.

Server

- Systems: Module scripts designed to operate on components.
- Components: Module scripts that return Stew factories.
- Modules: Random access modules for server side access only.

Client

- Systems: Module scripts designed to operate on components.
- Components: Module scripts that return Stew factories.
- Modules: Module scripts for client side access only.

Shared

- Modules

  - Schedules, this provides Sandwich schedule objects:
    - init: runs once before everything
    - boot: runs once after init
    - heartbeat: runs once every heartbeat after boot
    - gameTick: runs once every set heartbeats after boot

- World: a reference to the Stew World that houses all entities on the server and client.

- Globals: A script required by most scripts to give quick access to other scripts. Globals contains the following items in it's table.
  - Server: a reference to the Server Folder
  - Client: a reference to the Client Folder
  - Shared: a reference to the Shared Folder
  - Components: a reference to the server/client Components Folder
  - Systems: a reference to the server/client Components Folder
  - Packages: a reference to the Package module created by Wally
  - Vendor: a reference to the Vendor folder in Replicated Storage
  - Assets: a reference to the Assets folder in Replicated Storage
  - Config: a reference to the Config folder in Replicated Storage

# VS Code Snippets

- globals: creates a variable for ReplicatedStorage and the a required Globals module for easy access to Globals.
- package: creates a quick fill variable for requiring a module in the Packages folder. (requires a Globals variable set)
