/*******************************************************************************
* NOME DO ARQUIVO :        modules/gameplay/vehiclename.pwn
*
* DESCRIÇÃO :
*       Mostra o nome do veículo ao entrar.
*
* NOTAS :
*       -
*/

//------------------------------------------------------------------------------

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
    switch (newstate)
    {
        case PLAYER_STATE_DRIVER, PLAYER_STATE_PASSENGER:
        {
            ShowPlayerVehicleName(playerid);
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

ShowPlayerVehicleName(playerid, time = 8000)
{
    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleName[128];
        format(vehicleName, sizeof(vehicleName), "~n~~n~~n~~n~~n~~n~~n~~n~~g~                                           %s", GetVehicleName(GetPlayerVehicleID(playerid)));
        GameTextForPlayer(playerid, vehicleName, time, 3);
    }
    return 1;
}
