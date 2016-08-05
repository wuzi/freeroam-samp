/*******************************************************************************
* NOME DO ARQUIVO :        modules/gameplay/antitheft.pwn
*
* DESCRIÇÃO :
*       Impede que outros jogadores roubem o veículo de outros.
*
* NOTAS :
*       -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    if(!ispassenger && IsVehicleOccupied(vehicleid))
    {
        SendClientMessage(playerid, COLOR_WARNING, "* Você morreu por tentar roubar o veículo de outro jogador.");
        SetPlayerHealth(playerid, 0.0);
    }
    return 1;
}
