-- Function to find the mechanical user peripheral at runtime
local function findMechanicalUser()
    for _, name in ipairs(peripheral.getNames()) do
        if string.find(name, "xu2:tileuse_") then
            print("Found Mechanical User:", name)
            return peripheral.wrap(name)
        end
    end
    return nil  -- Return nil if no mechanical user is found
end

-- Wrap the modem to get the local name of the turtle
local modem = peripheral.wrap("bottom")  -- Modem is on the bottom
local turtleName = modem.getNameLocal()

-- Find the mechanical user at runtime
local mechanicalUser = findMechanicalUser()

if not mechanicalUser then
    error("Error: Mechanical User not found on the network!")
end

-- Ensure redstone outputs are off at start
print("Initializing redstone outputs to OFF")
redstone.setOutput("right", false)
redstone.setOutput("left", false)

-- Function to monitor idle state (slot 14 as trigger)
local function checkIdleState()
    local item = turtle.getItemDetail(14)
    if item then
        print("Item detected in slot 14: ", item.name)
    end
    return item ~= nil
end

-- Function to move item directly from turtle slot 14 to mechanical user slot 1
local function moveItemToMechanicalUser()
    if turtle.getItemDetail(14) then
        print("Moving item from slot 14 to Mechanical User slot 1")
        local success = mechanicalUser.pullItems(turtleName, 14, 1, 1)
        if success == 0 then
            error("Error: Failed to move item to Mechanical User")
        end
    end
end

-- Function to trigger redstone pulse
local function triggerRedstone(side)
    print("Triggering redstone pulse on", side)
    redstone.setOutput(side, true)
    sleep(0.1)  -- 0.1 seconds pulse
    redstone.setOutput(side, false)
end

-- Function to drop items from slots 1-13 onto the anvil
local function dropItemsOntoAnvil()
    print("Dropping items from slots 1-13 onto the anvil")
    for slot = 1, 13 do
        if turtle.getItemDetail(slot) then
            print("Dropping item from slot", slot)
            turtle.select(slot)
            turtle.drop()  -- Drops item below the turtle onto the anvil
        end
    end
end

-- Function to suck up the resulting item from the anvil into slot 16
local function suckUpResultingItem()
    print("Sucking up resulting item from the anvil into slot 16")
    turtle.select(16)
    turtle.suck()  -- Suck item from the anvil below the turtle
end

-- Function to return the crafting item left on the anvil to slot 15
local function returnItemFromMechanicalUser()
    print("Returning any item left in Mechanical User slot 1 to turtle slot 15")
    -- Trigger another redstone pulse on the right side
    triggerRedstone("right")
    
    -- Move item from mechanical user slot 1 to turtle slot 15
    local success = mechanicalUser.pushItems(turtleName, 1, 1, 15)
    if success == 0 then
        error("Error: Failed to move item back from Mechanical User to turtle")
    end
end

-- Main execution loop
while true do
    -- Check idle state (item in slot 14)
    if checkIdleState() then
        print("Starting crafting process")
        
        -- Move item from slot 14 to mechanical user slot 1
        moveItemToMechanicalUser()
        
        -- Trigger redstone output on the right (mechanical user activation)
        triggerRedstone("right")

        -- Drop items from slots 1-13 onto the anvil
        dropItemsOntoAnvil()

        -- Trigger redstone output on the left (Ya Hammer activation)
        triggerRedstone("left")

        -- Wait for a short period to allow crafting
        print("Waiting for crafting to complete...")
        sleep(2)  -- Adjust timing as necessary

        -- Suck up the resulting item into slot 16
        suckUpResultingItem()

        -- Return the crafting item from the mechanical user to slot 15
        returnItemFromMechanicalUser()
        
        print("Crafting process complete. Returning to idle state.")
    else
        -- Sleep briefly before checking again
        sleep(1)
    end
end
