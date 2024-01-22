# DarkRP Custom Chat Channels Addon

This addon enhances DarkRP by introducing custom chat channels for specific jobs. It allows tailored communication, enabling multiple jobs to participate in various channels.

# Installation

    Download the files.
    Place the files in your garrysmod/addons directory.

Usage
In-Game Configuration

    Open the configuration menu with the command: /chatconfig (Available to allowed user groups only).

Features

    Toggleable Categories: Mass select multiple jobs in categories and toggle them easily.
    Edit on the Fly: Make real-time changes to chat channels.

# Code Overview
cl_ui.lua

    This file contains the client-side code for the addon, handling UI creation and interaction.
sh_core.lua

    The core functionality is implemented in this shared file. It manages networking, chat functionality, and server-side operations.
sh_config.lua

    Configuration file defining allowed user groups, the command to open the configuration menu, and allowed user groups for each chat channel.
# Implementation Details

    Networking: Utilizes net messages for communication between client and server.
    Chat Functionality: Enables custom chat channels based on job roles.
    In-Game Config: Allowed user groups can access an in-game configuration menu to manage chat channels.

# Configuration: 
Adjust allowed user groups and configuration commands in sh_config.lua. Add or modify the allowedChannels table to specify allowed user groups for each chat channel.

# In-Game Commands

    /chatconfig: Open the configuration menu (accessible to allowed user groups only).

