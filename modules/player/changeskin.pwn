/*******************************************************************************
* NOME DO ARQUIVO :		modules/player/changeskin.pwn
*
* DESCRIÇÃO :
*	   Permite que os jogadores comprarem skins na loja de roupa.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

#define CLOTHES_PRICE               200

//------------------------------------------------------------------------------

static skinlist = mS_INVALID_LISTID;

//------------------------------------------------------------------------------

static gPickupID;
static gPlayerTickCount[MAX_PLAYERS];
static gIsModelSelectionVisible[MAX_PLAYERS];

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    skinlist = LoadModelSelectionMenu("skins.txt");
    gPickupID = CreateDynamicPickup(1275, 1, 208.8840, -100.7389, 1005.2578, 0, 15);
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerPickUpDynPickup(playerid, pickupid)
{
    if(pickupid == gPickupID && !gIsModelSelectionVisible[playerid] && gPlayerTickCount[playerid] < GetTickCount())
    {
        gIsModelSelectionVisible[playerid] = true;
        ShowModelSelectionMenu(playerid, skinlist, "Selecione a skin", 0x00000046, 0x6FA3FF99, 0x9ABEFFAA);
    }
}

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    gIsModelSelectionVisible[playerid] = false;
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerModelSelection(playerid, response, listid, modelid)
{
	if(listid == skinlist)
	{
		if(response)
		{
            if(GetPlayerCash(playerid) < CLOTHES_PRICE)
            {
                PlayErrorSound(playerid);
                SendClientMessagef(playerid, COLOR_ERROR, "* Você não tem dinheiro suficiente. ($%d)", CLOTHES_PRICE);
            }
            else
            {
                SetPlayerSkin(playerid, modelid);
                GivePlayerCash(playerid, -CLOTHES_PRICE);
                SendClientMessagef(playerid, COLOR_SUCCESS, "* Você trocou de skin. (-$%i)", CLOTHES_PRICE);
                SetSpawnInfo(playerid, 255, modelid, 1119.9399, -1618.7476, 20.5210, 91.8327, 0, 0, 0, 0, 0, 0);
                ApplyAnimation(playerid, "CLOTHES", "CLO_Buy", 4.1, 0, 1, 1, 0, 0);
            }
		}
        gPlayerTickCount[playerid] = GetTickCount() + 2500;
        gIsModelSelectionVisible[playerid] = false;
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:skin(playerid, params[], help)
{
    gIsModelSelectionVisible[playerid] = true;
    ShowModelSelectionMenu(playerid, skinlist, "Selecione a skin", 0x00000046, 0x6FA3FF99, 0x9ABEFFAA);
    return 1;
}
