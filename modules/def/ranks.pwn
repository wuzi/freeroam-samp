/*******************************************************************************
* NOME DO ARQUIVO :        modules/def/ranks.pwn
*
* DESCRIÇÃO :
*       Organizar os ID de ranks, admins.
*
* NOTAS :
*       -
*/

enum
{
    PLAYER_RANK_NONE,
    PLAYER_RANK_RECRUIT = 1,
    PLAYER_RANK_HELPER,
    PLAYER_RANK_MODERATOR,
    PLAYER_RANK_SUB_OWNER,
    PLAYER_RANK_OWNER
}

//------------------------------------------------------------------------------

stock GetPlayerRankColor(playerid)
{
    new rankColor = 0xFFFFFFFF;
    if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_OWNER)
        rankColor = COLOR_RANK_OWNER;
    else if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_SUB_OWNER)
        rankColor = COLOR_RANK_SUB_OWNER;
    else if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_MODERATOR)
        rankColor = COLOR_RANK_MODERATOR;
    else if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_HELPER)
        rankColor = COLOR_RANK_HELPER;
    else if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_RECRUIT)
        rankColor = COLOR_RANK_RECRUIT;
    return rankColor;
}

//------------------------------------------------------------------------------

stock GetPlayerAdminRankName(playerid, bool:capitalize = false)
{
    new rankName[12];
    if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_OWNER)
        rankName = "dono";
    else if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_SUB_OWNER)
        rankName = "sub-dono";
    else if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_MODERATOR)
        rankName = "moderador";
    else if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_HELPER)
        rankName = "ajudante";
    else if(GetPlayerAdminLevel(playerid) == PLAYER_RANK_RECRUIT)
        rankName = "recruta";
    else
        rankName = "jogador";
    if(capitalize == true)
        rankName[0] = toupper(rankName[0]);
    return rankName;
}
