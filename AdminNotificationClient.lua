local ReplicatedStorage = game:GetService("ReplicatedStorage")
local notificationEvent = ReplicatedStorage:WaitForChild("AdminNotification")

-- Function to display the notification
local function showNotification(message)
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local ScreenGui = Instance.new("ScreenGui", playerGui)
    local Frame = Instance.new("Frame", ScreenGui)
    local TextLabel = Instance.new("TextLabel", Frame)

    -- Configure the frame
    Frame.Size = UDim2.new(0.3, 0, 0.1, 0)
    Frame.Position = UDim2.new(0.35, 0, 0, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Dark background color
    Frame.BorderSizePixel = 0
    Frame.AnchorPoint = Vector2.new(0.5, 0) -- Center the frame

    -- Configure the text
    TextLabel.Text = message
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text color
    TextLabel.TextScaled = true
    TextLabel.TextWrapped = true
    TextLabel.TextStrokeTransparency = 0.5 -- Add a stroke to the text

    -- Animation for appearance
    Frame.Position = UDim2.new(0.35, 0, -0.2, 0) -- Initial position off-screen
    Frame:TweenPosition(UDim2.new(0.35, 0, 0, 0), "Out", "Quad", 0.5, true)

    wait(5) -- Display the notification for 5 seconds

    -- Animation for disappearance
    Frame:TweenPosition(UDim2.new(0.35, 0, -0.2, 0), "Out", "Quad", 0.5, true, function()
        ScreenGui:Destroy() -- Remove the notification after the animation
    end)
end

-- Listen for notifications
notificationEvent.OnClientEvent:Connect(showNotification) 
