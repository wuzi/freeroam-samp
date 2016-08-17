/*******************************************************************************
* NOME DO ARQUIVO :        modules/data/ranking.pwn
*
* DESCRIÇÃO :
*       Mostrar os jogadores do ranking do servidor.
*
* NOTES :
*       -
*
*
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

forward OnSelectScoreRanking(playerid);
forward OnSelectKillsRanking(playerid);
forward OnSelectRacesRanking(playerid);
forward OnSelectDerbyRanking(playerid);
forward OnSelectDeathRanking(playerid);

//------------------------------------------------------------------------------

YCMD:rank(playerid, params[], help)
{
    PlaySelectSound(playerid);
    ShowPlayerDialog(playerid, DIALOG_RANKING, DIALOG_STYLE_LIST, "Ranks", "Score\nAbates\nCorridas\nDerby\nMata-Mata", "Selecionar", "Voltar");
    return 1;
}

//------------------------------------------------------------------------------

public OnSelectScoreRanking(playerid)
{
    new rows, fields, output[4096], string[48], username[MAX_PLAYER_NAME], score;
	cache_get_data(rows, fields, gMySQL);
    strcat(output, "Rank\tNome\tPontos\n");
    for(new i = 0; i < rows; i++)
    {
        score = cache_get_field_content_int(i, "score", gMySQL);
        cache_get_field_content(i, "username", username, gMySQL, MAX_PLAYER_NAME);
        format(string, sizeof(string), "%iº\t%s\t%d\n", i + 1, username, score);
        strcat(output, string);
    }
    ShowPlayerDialog(playerid, DIALOG_RANKING_SCORE, DIALOG_STYLE_TABLIST_HEADERS, "Ranking: Score", output, "Voltar", "");
    return 1;
}

//------------------------------------------------------------------------------

public OnSelectKillsRanking(playerid)
{
    new rows, fields, output[4096], string[48], username[MAX_PLAYER_NAME], kills;
	cache_get_data(rows, fields, gMySQL);
    strcat(output, "Rank\tNome\tAbates\n");
    for(new i = 0; i < rows; i++)
    {
        kills = cache_get_field_content_int(i, "kills", gMySQL);
        cache_get_field_content(i, "username", username, gMySQL, MAX_PLAYER_NAME);
        format(string, sizeof(string), "%iº\t%s\t%d\n", i + 1, username, kills);
        strcat(output, string);
    }
    ShowPlayerDialog(playerid, DIALOG_RANKING_KILLS, DIALOG_STYLE_TABLIST_HEADERS, "Ranking: Abates", output, "Voltar", "");
    return 1;
}

//------------------------------------------------------------------------------

public OnSelectRacesRanking(playerid)
{
    new rows, fields, output[4096], string[48], username[MAX_PLAYER_NAME], races;
	cache_get_data(rows, fields, gMySQL);
    strcat(output, "Rank\tNome\tVitórias\n");
    for(new i = 0; i < rows; i++)
    {
        races = cache_get_field_content_int(i, "race_wins", gMySQL);
        cache_get_field_content(i, "username", username, gMySQL, MAX_PLAYER_NAME);
        format(string, sizeof(string), "%iº\t%s\t%d\n", i + 1, username, races);
        strcat(output, string);
    }
    ShowPlayerDialog(playerid, DIALOG_RANKING_RACES, DIALOG_STYLE_TABLIST_HEADERS, "Ranking: Corridas", output, "Voltar", "");
    return 1;
}

//------------------------------------------------------------------------------

public OnSelectDerbyRanking(playerid)
{
    new rows, fields, output[4096], string[48], username[MAX_PLAYER_NAME], derby;
	cache_get_data(rows, fields, gMySQL);
    strcat(output, "Rank\tNome\tVitórias\n");
    for(new i = 0; i < rows; i++)
    {
        derby = cache_get_field_content_int(i, "derby_wins", gMySQL);
        cache_get_field_content(i, "username", username, gMySQL, MAX_PLAYER_NAME);
        format(string, sizeof(string), "%iº\t%s\t%d\n", i + 1, username, derby);
        strcat(output, string);
    }
    ShowPlayerDialog(playerid, DIALOG_RANKING_DERBY, DIALOG_STYLE_TABLIST_HEADERS, "Ranking: Derby", output, "Voltar", "");
    return 1;
}

//------------------------------------------------------------------------------

public OnSelectDeathRanking(playerid)
{
    new rows, fields, output[4096], string[48], username[MAX_PLAYER_NAME], death_wins;
	cache_get_data(rows, fields, gMySQL);
    strcat(output, "Rank\tNome\tVitórias\n");
    for(new i = 0; i < rows; i++)
    {
        death_wins = cache_get_field_content_int(i, "dm_wins", gMySQL);
        cache_get_field_content(i, "username", username, gMySQL, MAX_PLAYER_NAME);
        format(string, sizeof(string), "%iº\t%s\t%d\n", i + 1, username, death_wins);
        strcat(output, string);
    }
    ShowPlayerDialog(playerid, DIALOG_RANKING_DM, DIALOG_STYLE_TABLIST_HEADERS, "Ranking: Mata-Mata", output, "Voltar", "");
    return 1;
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_RANKING:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        mysql_tquery(gMySQL, "SELECT username, score FROM users ORDER BY score DESC LIMIT 95", "OnSelectScoreRanking", "i", playerid);
                    }
                    case 1:
                    {
                        mysql_tquery(gMySQL, "SELECT username, kills FROM users ORDER BY kills DESC LIMIT 95", "OnSelectKillsRanking", "i", playerid);
                    }
                    case 2:
                    {
                        mysql_tquery(gMySQL, "SELECT username, race_wins FROM users ORDER BY race_wins DESC LIMIT 95", "OnSelectRacesRanking", "i", playerid);
                    }
                    case 3:
                    {
                        mysql_tquery(gMySQL, "SELECT username, derby_wins FROM users ORDER BY derby_wins DESC LIMIT 95", "OnSelectDerbyRanking", "i", playerid);
                    }
                    case 4:
                    {
                        mysql_tquery(gMySQL, "SELECT username, dm_wins FROM users ORDER BY dm_wins DESC LIMIT 95", "OnSelectDeathRanking", "i", playerid);
                    }
                }
            }
        }
        case DIALOG_RANKING_SCORE, DIALOG_RANKING_KILLS, DIALOG_RANKING_RACES, DIALOG_RANKING_DERBY, DIALOG_RANKING_DM:
        {
            PlayCancelSound(playerid);
            ShowPlayerDialog(playerid, DIALOG_RANKING, DIALOG_STYLE_LIST, "Ranks", "Score\nAbates\nCorridas\nDerby\nMata-Mata", "Selecionar", "Voltar");
        }
    }
    return 1;
}
