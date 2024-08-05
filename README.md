# Ortho Games Framework

Ortho Games Framework is a framework designed by the Ortho Games studio to make development:

- fast
- easy
- intuitive
- linearly complex.

The main method we use to achieve that end is to use a hybrid ECS and event driven approach to make the development process scale, while still being intuitive for developers in the Roblox ecosystem.

# Structure

The structure of our projects follows a one script architecture pattern with a one folder per feature style of organization. Generally we have one folder in the client/server/shared area that encompasses an idea, for example "Player" is a common folder we use to keep track of players joining and leaving and characters being created and killed. Within that folder we have three sub-folders.

- Components -- Modules that return component factories.
- Jobs -- Modules that return schedule jobs.
- Modules -- Modules that return function libraries, or functions, and/or keep track of global information.

# Why ECS? What ECS?

One problem we've run into many times as a development team is interdependency of modules on other systems. ECS allows data to be completely separated from the functionality, which allows code to require components all they want without components ever requiring jobs making the layout of the game horizontal rather than strongly vertical. Jobs are usually the only code that requires across features, and jobs can't be required for any use other than dependency in the scheduler. This allows us to enforce good principled interfaces with signals. 

Our ECS of choice is the public ECS Framework by our friends over at Data Oriented House, Stew. We chose Stew because we believe that other popular ECS frameworks are too limiting or rigid in their structure that forces developers into often times uncomfortable patterns for Roblox which is such an event driven environment. Stew allows us to be creative and unconstrained in how we write our systems to update and manage, and even register and add our components. This freedom of choice across the development environment is what we believe allows us to make games quickly and effectively.

# What are Jobs?

Another tool by our friends at Data Oriented House is Sandwich. Sandwich is a scheduler tool that allows you to create synchronous ordered execution lists of functions that give you the control to allow certain functions to be executed only after other functions have been executed. By requiring all modules in our boot function and then each module having access to global schedules they can add themselves too, we can create an architecture where each piece is responsible for it's own execution only depending on that schedule to exist and be started at some point. The two main schedules we have are Init, and Boot. Init happens first, in this step all you should really be doing is connecting events inside your jobs. On Boot is when the main engine of the game should start up so you can be sure the events setup inside init jobs will actually receive their events.

# Bridging The ECS Gap

Out of the box Stew does not support events in their system, but Roblox is so event driven how do you bridge the gap? The main ways we bridge this gap is by adding signals for when components are added, removed, or changed. One of the main driving forces behind our games is the "InjectLifecycleSignals" function that adds onAdded and onRemoved events to components at their creation. For component tracking we make use of TableValue a simple proxy table wrapper to hook in functions and therefore signals into components. We can use that to keep track of all our data.

# User Interface

In the time of writing this article modern UI design principles focus on this idea of reactive state that dynamically and smoothly transitions UI based on the change of that state. One of the current popular libraries that are built on this idea is Fusion. In our framework we use Fusion as a way to connect components, and events on the client side to easily build out complex ui systems with an intuitive reactive state. This allows developers to create complex ui systems with relative ease and hook up pre-made UI assets for easy team development.

# OrthoUtil

One of the strongest tools in the framework is the OrthoUtil that has a variety of random pure functions that can ease the strain of simple repeated simple or complex ideas that can get in the way of development fluidity. With the arsenal of functions in OrthoUtil it allows us to bring conceptualization to reality at a faster more efficient pace by solving common problems we don't have to think about.

# The Beating Heart of Ortho Games Framework

At the core of everything we have the Global folder inside of Shared. This folder gives quick access to World for Stew, Schedules from Sandwich, and InjectLifecycleSignals for Components.

# We're Evolving

Every project we take on and every new challenge we face we adapt our approach to improve the framework to fit our needs. The key to game development is understanding that one size does not fit all, all the time. Sometimes you will want to break the pattern in order to accommodate some specific feature you want that is vital to your game. This is why the Ortho Games framework is simple, and founded on basic widely applicable principles.