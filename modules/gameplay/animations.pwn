/*******************************************************************************
* NOME DO ARQUIVO :		modules/gameplay/animations.pwn
*
* DESCRIÇÃO :
*	   Adiciona comandos para que jogadores possam executar animações.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

static gPlayerUsingLoopingAnim[MAX_PLAYERS];
static gPlayerAnimLibsPreloaded[MAX_PLAYERS];

static Text:txtAnimHelper;

//------------------------------------------------------------------------------

OnePlayAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
}

//------------------------------------------------------------------------------

LoopingAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
    gPlayerUsingLoopingAnim[playerid] = 1;
    ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
    TextDrawShowForPlayer(playerid,txtAnimHelper);
}

//------------------------------------------------------------------------------
StopLoopingAnim(playerid)
{
	gPlayerUsingLoopingAnim[playerid] = 0;
    ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
}

//------------------------------------------------------------------------------

PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);
}

//------------------------------------------------------------------------------

IsKeyJustDown(key, newkeys, oldkeys)
{
	if((newkeys & key) && !(oldkeys & key)) return 1;
	return 0;
}

//------------------------------------------------------------------------------


hook OnPlayerDisconnect(playerid, reason)
{
    gPlayerUsingLoopingAnim[playerid] = 0;
	gPlayerAnimLibsPreloaded[playerid] = 0;
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(gPlayerUsingLoopingAnim[playerid])
    {
        if(IsKeyJustDown(KEY_SPRINT, newkeys, oldkeys))
        {
    	    StopLoopingAnim(playerid);
            TextDrawHideForPlayer(playerid, txtAnimHelper);
        }
    }
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    txtAnimHelper = TextDrawCreate(610.0, 400.0,
	"~r~~k~~PED_SPRINT~ ~w~para parar o anim");
	TextDrawUseBox(txtAnimHelper, 0);
	TextDrawFont(txtAnimHelper, 2);
	TextDrawSetShadow(txtAnimHelper,0); // no shadow
    TextDrawSetOutline(txtAnimHelper,1); // thickness 1
    TextDrawBackgroundColor(txtAnimHelper,0x000000FF);
    TextDrawColor(txtAnimHelper,0xFFFFFFFF);
    TextDrawAlignment(txtAnimHelper,3); // align right

    Command_AddAltNamed("animes",		"animlist");
    Command_AddAltNamed("animes",		"anims");
    Command_AddAltNamed("animes",		"anim");
    Command_AddAltNamed("handsup",		"renderse");
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerSpawn(playerid)
{
    if(!gPlayerAnimLibsPreloaded[playerid]) {
   		PreloadAnimLib(playerid,"BOMBER");
   		PreloadAnimLib(playerid,"RAPPING");
    	PreloadAnimLib(playerid,"SHOP");
   		PreloadAnimLib(playerid,"BEACH");
   		PreloadAnimLib(playerid,"SMOKING");
    	PreloadAnimLib(playerid,"FOOD");
    	PreloadAnimLib(playerid,"ON_LOOKERS");
    	PreloadAnimLib(playerid,"DEALER");
		PreloadAnimLib(playerid,"CRACK");
		PreloadAnimLib(playerid,"CARRY");
		PreloadAnimLib(playerid,"COP_AMBIENT");
		PreloadAnimLib(playerid,"PARK");
		PreloadAnimLib(playerid,"INT_HOUSE");
		PreloadAnimLib(playerid,"FOOD");
		PreloadAnimLib(playerid,"PED");
		PreloadAnimLib(playerid,"CLOTHES");
		gPlayerAnimLibsPreloaded[playerid] = 1;
	}
    return 1;
}

//------------------------------------------------------------------------------

YCMD:animes(playerid, params[], help)
{
	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Animações ----------------------------------------");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /renderse - /bebado - /bomba - /mirar - /rir - /roubar - /cruzarbracos - /verhoras - /medo - /crack - /fumar");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /lavarmaos - /sentar - /sentarcadeira - /falar - /tapanabunda - /deitar - /levantar - /abrirportao - /pegarbebida");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /chamargarcom - /lembrar - /mostrar - /graffiti - /chorar - /triste - /beber - /comer - /preparar - /vomitar - /dancar");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /masturbar - /apontar - /acenar - /taichi - /mijar - /mecherboca - /pensar");
	SendClientMessage(playerid, COLOR_TITLE, "---------------------------------------- Animações ----------------------------------------");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:handsup(playerid, params[], help)
{
	if(IsPlayerInEvent(playerid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode usar este comando no evento.");

    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_HANDSUP);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:bebado(playerid, params[], help)
{
    LoopingAnim(playerid,"PED","WALK_DRUNK",4.0, 1, 1, 1, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:bomba(playerid, params[], help)
{
    ClearAnimations(playerid);
	LoopingAnim(playerid, "BOMBER", "BOM_Plant", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:mirar(playerid, params[], help)
{
    LoopingAnim(playerid,"PED", "ARRESTgun", 4.0, 0, 1, 1, 1, -1);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:rir(playerid, params[], help)
{
    OnePlayAnim(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:roubar(playerid, params[], help)
{
    LoopingAnim(playerid, "SHOP", "ROB_Loop_Threat", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:cruzarbracos(playerid, params[], help)
{
    LoopingAnim(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 0, 1, 1, 1, -1);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:pensar(playerid, params[], help)
{
    OnePlayAnim(playerid, "COP_AMBIENT", "Coplook_think", 3.5, 0, 1, 1, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:verhoras(playerid, params[], help)
{
    OnePlayAnim(playerid, "COP_AMBIENT", "Coplook_watch", 3.5, 0, 1, 1, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:medo(playerid, params[], help)
{
    LoopingAnim(playerid, "PED", "cower", 3.0, 1, 0, 0, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:crack(playerid, params[], help)
{
    new id;
    if(sscanf(params, "d", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /crack [1-5]");
    }
    else
    {
        switch (id)
        {
            case 1:
                LoopingAnim(playerid, "CRACK", "crckidle1", 4.0, 1, 0, 0, 1, 0);
            case 2:
                LoopingAnim(playerid, "CRACK", "crckidle2", 4.0, 1, 0, 0, 1, 0);
            case 3:
                LoopingAnim(playerid, "CRACK", "crckidle4", 4.0, 1, 0, 0, 1, 0);
            case 4:
                LoopingAnim(playerid, "CRACK", "crckdeth3", 4.0, 0, 0, 0, 0, 0);
            case 5:
                LoopingAnim(playerid, "CRACK", "crckidle3", 4.0, 1, 0, 0, 0, 0);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:fumar(playerid, params[], help)
{
	if(IsPlayerInEvent(playerid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode usar este comando no evento.");

    new id;
    if(sscanf(params, "d", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /fumar [1-3]");
    }
    else
    {
        switch (id)
        {
            case 1:
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
            case 2:
                LoopingAnim(playerid,"SMOKING", "M_smklean_loop", 4.0, 1, 0, 0, 0, 0);
            case 3:
                LoopingAnim(playerid, "SMOKING", "F_smklean_loop", 4.0, 1, 0, 0, 0, 4000);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:lavarmaos(playerid, params[], help)
{
    OnePlayAnim(playerid,"INT_HOUSE","wash_up", 3.0, 0, 1, 1, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:sentar(playerid, params[], help)
{
    new id;
    if(sscanf(params, "d", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /sentar [1-3]");
    }
    else
    {
        switch (id)
        {
            case 1:
                LoopingAnim(playerid,"BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0);
            case 2:
                LoopingAnim(playerid,"MISC", "Seat_Talk_01", 4.0, 1, 0, 0, 1, 0);
            case 3:
                LoopingAnim(playerid,"MISC", "Seat_Talk_02", 4.0, 1, 0, 0, 1, 0);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:sentarcadeira(playerid, params[], help)
{
    LoopingAnim(playerid,"BAR","dnk_stndF_loop",4.0,1,0,0,0,0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:falar(playerid, params[], help)
{
    OnePlayAnim(playerid,"PED","IDLE_CHAT",4.0,0,0,0,0,0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:tapanabunda(playerid, params[], help)
{
    OnePlayAnim(playerid, "SWEET", "sweet_ass_slap", 4.0, 0, 0, 0, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:deitar(playerid, params[], help)
{
    LoopingAnim(playerid,"BEACH", "bather", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:levantar(playerid, params[], help)
{
    OnePlayAnim(playerid,"Attractors", "Stepsit_out", 3.0, 0, 1, 1, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:abrirportao(playerid, params[], help)
{
    OnePlayAnim(playerid, "AIRPORT", "thrw_barl_thrw", 3.0, 0, 1, 1, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:pegarbebida(playerid, params[], help)
{
    OnePlayAnim(playerid,"BAR", "Barcustom_get", 4.0, 0, 1, 1, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:chamargarcom(playerid, params[], help)
{
    OnePlayAnim(playerid,"BAR", "Barcustom_order", 4.0, 0, 1, 1, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:lembrar(playerid, params[], help)
{
    new id;
    if(sscanf(params, "i", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /lembrar [1-2]");
    }
    else
    {
        switch (id)
        {
            case 1:
                OnePlayAnim(playerid,"GANGS", "smkcig_part", 4.0, 0, 1, 1, 0, 0);
            case 2:
                OnePlayAnim(playerid,"GANGS", "smkcig_part_F", 4.0, 0, 1, 1, 0, 0);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:mostrar(playerid, params[], help)
{
    new id;
    if(sscanf(params, "i", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /mostrar [1-2]");
    }
    else
    {
        switch (id)
        {
            case 1:
                OnePlayAnim(playerid,"GHANDS", "gsign1LH", 4.0, 0, 1, 1, 0, 0);
            case 2:
                OnePlayAnim(playerid,"GANGS", "gsign2LH", 4.0, 0, 1, 1, 0, 0);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:graffiti(playerid, params[], help)
{
    OnePlayAnim(playerid,"GRAFFITI", "spraycan_fire", 4.0, 0, 1, 1, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:chorar(playerid, params[], help)
{
    new id;
    if(sscanf(params, "i", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /chorar [1-2]");
    }
    else
    {
        switch (id)
        {
            case 1:
                LoopingAnim(playerid,"GRAVEYARD", "mrnM_loop", 4.0, 1, 0, 0, 1, 0);
            case 2:
                LoopingAnim(playerid,"GRAVEYARD", "mrnF_loop", 4.0, 1, 0, 0, 1, 0);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:triste(playerid, params[], help)
{
    LoopingAnim(playerid, "GRAVEYARD", "prst_loopa", 4.0, 1, 0, 0, 1, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:beber(playerid, params[], help)
{
	if(IsPlayerInEvent(playerid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode usar este comando no evento.");

    new id;
    if(sscanf(params, "i", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /beber [1-5]");
    }
    else
    {
        switch (id)
        {
            case 1:
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_WINE);
            case 2:
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_SPRUNK);
            case 3:
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_BEER);
            case 4:
                OnePlayAnim(playerid,"BAR", "dnk_stndM_loop", 4.0, 0, 1, 1, 0, 0);
            case 5:
                OnePlayAnim(playerid,"BAR", "dnk_stndF_loop", 4.0, 0, 1, 1, 0, 0);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:preparar(playerid, params[], help)
{
    OnePlayAnim(playerid, "benchpress", "gym_bp_celebrate", 4.0, 0, 1, 1, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:vomitar(playerid, params[], help)
{
    OnePlayAnim(playerid, "FOOD", "EAT_Vomit_P", 4.1, 0, 1, 1, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:masturbar(playerid, params[], help)
{
    LoopingAnim(playerid,"MISC", "Scratchballs_01", 4.0, 1, 1, 1, 1, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:mecherboca(playerid, params[], help)
{
    LoopingAnim(playerid,"PED", "facsurp", 4.0, 0, 1, 1, 0, 0);
    return 1;
}

//------------------------------------------------------------------------------

YCMD:comer(playerid, params[], help)
{
    new id;
    if(sscanf(params, "i", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /comer [1-3]");
    }
    else
    {
        switch (id)
        {
            case 1:
                OnePlayAnim(playerid, "FOOD", "EAT_Burger", 4.0, 0, 1, 1, 0, 0);
            case 2:
                OnePlayAnim(playerid, "FOOD", "EAT_Chicken", 4.0, 0, 1, 1, 0, 0);
            case 3:
                OnePlayAnim(playerid, "FOOD", "EAT_Pizza", 4.0, 0, 1, 1, 0, 0);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:dancar(playerid, params[], help)
{
	if(IsPlayerInEvent(playerid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode usar este comando no evento.");

    new id;
    if(sscanf(params, "i", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /dancar [1-15]");
    }
    else
    {
        switch (id)
        {
            case 1:
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE1);
            case 2:
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE2);
            case 3:
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE3);
            case 4:
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE4);
            case 5:
                LoopingAnim(playerid,"DANCING", "dance_loop", 4.0, 1, 0, 0, 1, 0);
            case 6:
                LoopingAnim(playerid,"DANCING", "DAN_Down_A", 4.0, 1, 0, 1, 1, 0);
            case 7:
                LoopingAnim(playerid,"DANCING", "DAN_Left_A", 4.0, 1, 0, 1, 1, 0);
            case 8:
                LoopingAnim(playerid,"DANCING", "DAN_Loop_A", 4.0, 1, 0, 1, 1, 0);
            case 9:
                LoopingAnim(playerid,"DANCING", "DAN_Right_A", 4.0, 1, 0, 1, 1, 0);
            case 10:
                LoopingAnim(playerid,"DANCING", "DAN_Up_A", 4.0, 1, 0, 0, 1, 0);
            case 11:
                LoopingAnim(playerid,"DANCING", "dnce_M_a", 4.0, 1, 0, 0, 1, 0);
            case 12:
                LoopingAnim(playerid,"DANCING", "dnce_M_b", 4.0, 1, 0, 0, 1, 0);
            case 13:
                LoopingAnim(playerid,"DANCING", "dnce_M_c", 4.0, 1, 0, 0, 1, 0);
            case 14:
                LoopingAnim(playerid,"DANCING","dnce_M_d", 4.0, 1, 0, 0, 1, 0);
            case 15:
                LoopingAnim(playerid,"DANCING","dnce_M_e", 4.0, 1, 0, 0, 1, 0);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:apontar(playerid, params[], help)
{
    new id;
    if(sscanf(params, "i", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /apontar [1-2]");
    }
    else
    {
        switch (id)
        {
            case 1:
                LoopingAnim(playerid,"ON_LOOKERS", "point_loop", 4.0, 1, 1, 1, 1, 0);
            case 2:
                OnePlayAnim(playerid,"ON_LOOKERS", "point_out", 4.0, 0, 1, 1, 0, 0);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:acenar(playerid, params[], help)
{
    new id;
    if(sscanf(params, "i", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /acenar [1-2]");
    }
    else
    {
        switch (id)
        {
            case 1:
                LoopingAnim(playerid,"ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 1, 0);
            case 2:
                OnePlayAnim(playerid,"ON_LOOKERS", "wave_out", 4.0, 0, 1, 1, 0, 0);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:taichi(playerid, params[], help)
{
    new id;
    if(sscanf(params, "i", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /taichi [1-2]");
    }
    else
    {
        switch (id)
        {
            case 1:
                OnePlayAnim(playerid,"PARK", "Tai_Chi_Out", 4.0, 0, 1, 1, 0, 0);
            case 2:
                LoopingAnim(playerid,"PARK", "Tai_Chi_Loop", 4.0, 1, 0, 0, 1, 0);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

YCMD:mijar(playerid, params[], help)
{
	if(IsPlayerInEvent(playerid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode usar este comando no evento.");

    new id;
    if(sscanf(params, "i", id))
    {
        SendClientMessage(playerid, COLOR_INFO, "* /mijar [1-4]");
    }
    else
    {
        switch (id)
        {
            case 1:
                SetPlayerSpecialAction(playerid, 68);
            case 2:
                OnePlayAnim(playerid,"PAULNMAC", "Piss_out", 4.0, 0, 1, 1, 0, 0);
            case 3:
                LoopingAnim(playerid,"PAULNMAC", "Piss_in", 4.0, 0, 1, 1, 1, 0);
            case 4:
                LoopingAnim(playerid,"PAULNMAC", "Piss_loop",4.0, 1, 0, 0, 1, 0);
            default:
                SendClientMessage(playerid, COLOR_ERROR, "* Número inválido.");
        }
    }
    return 1;
}
