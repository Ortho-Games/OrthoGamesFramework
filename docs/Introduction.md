# Introduction

Version 0.5.0

Orthogonal Games Framework is a game framework based on the ECS system Stew and makes heavy use of the Buffet Bundle Toolchain provided and maintained by Data Oriented House.

This project serves an example project meant to showcase the usage and guide for different patterns required to use the system for effective game development.

# Overview

Modules

Loaders

- Provides basic boot for both server & client scripts. Each script implements a descendants module require and the functionality for each schedules start calls.

Server

- Classes: Module scripts that are meant to build prebuilt objects by creating new entities and adding on default components.

- Core: Groups of files for organization purposes.
  - Group Folder: A folder for a group of related components folders.
    - Components: A folder for holding component modules related to the group.
    - Jobs: A folder for holding modules that return sandwich jobs for global jobs.
    - Modules: Modules that contain libraries of functions related to the group.
    - Functions: Modules that return functions.
    - Types: Modules that hold exported types used by the group.

Client

- Classes: Module scripts that are meant to build prebuilt objects by creating new entities and adding on default components.

- Core: Groups of files for organization purposes.
  - Group Folder: A folder for a group of related components folders, this folder can also house subgroups.
    - Components: A folder for holding component modules related to the group.
    - Jobs: A folder for holding modules that return sandwich jobs for global jobs.
    - Modules: Modules that contain libraries of functions related to the group.
    - Functions: Modules that return functions.
    - Enums: Modules that hold lists of predefined lists of categories.
    - Types.lua: A module that hold exported types used by the group.

Shared

- Config: Folder for housing module files that provide configuration for various modules.
- Modules

  - Schedules, this provides Sandwich schedule objects:
    - init: runs once before everything
    - boot: runs once after init
    - heartbeat: runs once every heartbeat after boot
    - gameTick: runs once every set heartbeats after boot

- Globals: A script required by most scripts to give quick access to other scripts. Globals contains the following items in it's table.
  - Local: a reference to the Server or Client folder depending on where Globals is required from.
  - Shared: a reference to the Shared Folder
  - Packages: a reference to the Package module created by Wally
  - Vendor: a reference to the Vendor folder in Replicated Storage
  - Assets: a reference to the Assets folder in Replicated Storage
  - Config: a reference to the Config folder in Replicated Storage

# VS Code Snippets

- globals: creates a variable for ReplicatedStorage and the a required Globals module for easy access to Globals.
- package: creates a quick fill variable for requiring a module in the Packages folder. (requires a Globals variable set)
