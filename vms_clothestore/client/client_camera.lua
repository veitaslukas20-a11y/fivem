local cam = nil
local cameraOffset = nil

local cameraFov = 0.0

local defaultPosition = vector3(0.0, 0.0, 0.0)
local camPosition = vector3(0.0, 0.0, 0.0)
local playerPosition = nil

local currentCam = nil

function CreateCamera()
    if not DoesCamExist(cam) then
        cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.CameraSettings.startingFov, true, 4)
    end

    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local myHeading = GetEntityHeading(myPed)
    cameraOffset = GetOffsetFromEntityInWorldCoords(myPed, 0.0, 0.0 + Config.DefaultCamDistance, 0.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 700, true, true)

    playerPosition = myCoords
    camPosition = vec(cameraOffset.x, cameraOffset.y, cameraOffset.z+0.65)
    defaultPosition = vec(cameraOffset.x, cameraOffset.y, cameraOffset.z)
    cameraFov = Config.CameraSettings.startingFov

    SetCamParams(cam, camPosition.x, camPosition.y, camPosition.z, 0.0, 0.0, 0.0, cameraFov, 2000.0, 0, 0, 2)
    PointCamAtCoord(cam, myCoords.x, myCoords.y, myCoords.z+0.65)
    SetCamFov(cam, cameraFov)
    if Config.BlurBehindPlayer then
        SetTimecycleModifier('MP_corona_heist_DOF')
        SetTimecycleModifierStrength(1.0)
    end
end

function DeleteCamera()
    SetCamActive(cam, false)
    cam = nil
    RenderScriptCams(false, true, 500, true, true)
    if Config.BlurBehindPlayer then
        ClearTimecycleModifier()
    end
end

function changeCameraHeight(direction, value)
    local newValue = direction == 'top' and value * 0.01 or -value * 0.01
    if direction == 'top' and (camPosition.z + newValue < (playerPosition.z + Config.CameraSettings.maxCameraHeight)) or direction == 'bottom' and (camPosition.z + newValue > (playerPosition.z + Config.CameraSettings.minCameraHeight)) then
        camPosition = vec(cameraOffset.x, cameraOffset.y, camPosition.z + newValue)
    end
    SetCamParams(cam, camPosition.x, camPosition.y, camPosition.z, 0.0, 0.0, 0.0, cameraFov, 2000.0, 0, 0, 2)
    SetCamFov(cam, cameraFov)
    PointCamAtCoord(cam, camPosition.x, camPosition.y, camPosition.z)
end

RegisterNUICallback('upate_camera', function(data, cb)
    if data.direction == 'top' or data.direction == 'bottom' then
        changeCameraHeight(data.direction, data.value)
    end
    if data.direction == 'left' or data.direction == 'right' then
        SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId())+(data.direction == 'left' and -data.value or data.value))
    end
end)

RegisterNUICallback("update_camera_zoom", function(data)
    if cam and data.type then
        if data.type == 'plus' and cameraFov - 1.5 > Config.CameraSettings.minCameraFov or data.type == 'minus' and cameraFov + 1.5 < Config.CameraSettings.maxCameraFov then
            cameraFov = data.type == 'plus' and cameraFov - 1.5 or cameraFov + 1.5
            SetCamFov(cam, cameraFov)
        end
    end
end)

RegisterNUICallback("change_camera", function(data)
    if cam and data.type then
        if currentCam ~= data.type then
            currentCam = data.type
            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)
            local newCamPos = Config.CameraHeight[data.type]
            camPosition = vec(defaultPosition.x, defaultPosition.y, defaultPosition.z + newCamPos.z_height)
            SetCamCoord(cam, camPosition.x, camPosition.y, camPosition.z)
            PointCamAtCoord(cam, camPosition.x, camPosition.y, camPosition.z)
            cameraFov = newCamPos.fov
            SetCamFov(cam, newCamPos.fov)
        end
    end
end)