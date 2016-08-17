/*******************************************************************************
* NOME DO ARQUIVO :        modules/gameplay/anticheat.pwn
*
* DESCRIÇÃO :
*       Responsável por dar as punições aos jogadores suspeitos de cheating
*
* NOTAS :
*       -
*/

#include <YSI\y_hooks>

static gPlayerCheatCount[MAX_PLAYERS][53];

//------------------------------------------------------------------------------

static const g_anticheat_names[][] =
{
    "air-breaking",
    "air-breaking",
    "teleport-hack",
    "teleport-hack",
    "teleport-hack",
    "teleport-hack",
    "teleport-hack",
    "fly-hack",
    "fly-hack",
    "speed hack",
    "speed hack",
    "health hack",
    "health hack",
    "armour hack",
    "money hack",
    "weapon hack",
    "ammo hack",
    "ammo hack",
    "anti anim hack",
    "godmode hack",
    "godmode hack",
    "invisible hack",
    "lagcomp hack",
    "tuning hack",
    "parkour mod",
    "quick turn",
    "rapid fire",
    "fake spawn",
    "fake kill",
    "auto aim",
    "CJ run",
    "carShot",
    "carJack",
    "descongelar hack",
    "AFK Ghost",
    "full aiming",
    "fake NPC",
    "reconnect",
    "ping alto",
    "dialog hack",
    "sandbox protection",
    "invalid version",
    "rcon hack",
    "tuning crasher",
    "assento de veículo inválido",
    "dialog crasher",
    "attached object crasher",
    "weapon crasher",
    "flood",
    "flood",
    "flood",
    "ddos",
    "sobeit NOP"
};

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    for(new i = 0; i < sizeof(gPlayerCheatCount[]); i++)
    {
        gPlayerCheatCount[playerid][i] = 0;
    }
    return 1;
}

//------------------------------------------------------------------------------

forward OnCheatDetected(playerid, ip_address[], type, code);
public OnCheatDetected(playerid, ip_address[], type, code)
{
    if(!type)
    {
        gPlayerCheatCount[playerid][code]++;
        if(gPlayerCheatCount[playerid][code] >= 3)
        {
            new count = 0;
            foreach(new i: Player)
            {
                if(GetPlayerAdminLevel(i) >= PLAYER_RANK_RECRUIT)
                {
                    count++;
                }
            }

            if(count)
                SendAdminMessage(PLAYER_RANK_RECRUIT, COLOR_LIGHT_RED, "[ANTICHEAT] O jogador %s foi acusado de suspeitas de %s.", GetPlayerNamef(playerid), g_anticheat_names[code]);
            else
            {
                SendClientMessageToAllf(COLOR_LIGHT_RED, "[ANTICHEAT] O jogador %s foi kickado do servidor. Motivo: Suspeitas de %s.", GetPlayerNamef(playerid), g_anticheat_names[code]);
                Kick(playerid);
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

ptask OnResetFalsePositives[30000](playerid)
{
    for(new i = 0; i < sizeof(gPlayerCheatCount[]); i++)
    {
        if(gPlayerCheatCount[playerid][i] > 0)
            gPlayerCheatCount[playerid][i]--;
    }
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    EnableAntiCheat(2, false);
    EnableAntiCheat(3, false);
    EnableAntiCheat(4, false);
    EnableAntiCheat(5, false);
    EnableAntiCheat(6, false);
    EnableAntiCheat(21, false);
    EnableAntiCheat(27, false);
    EnableAntiCheat(39, false);
    EnableAntiCheat(38, false);
    EnableAntiCheat(37, false);
    EnableAntiCheat(14, false);
    return 1;
}
