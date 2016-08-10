/*******************************************************************************
* NOME DO ARQUIVO :        modules/data/player.pwn
*
* DESCRIÇÃO :
*       Manipula a conta dos jogadores, salvar, carregar, cadastrar, acessar.
*
* NOTES :
*       Este arquivo deve apenas conter dados de jogadores.
*
*
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

forward OnNameCheck(playerid, name[]);
forward OnEmailCheck(playerid, email[]);
forward OnAccountLoad(playerid);
forward OnAccountCheck(playerid);
forward OnAccountRegister(playerid);
forward OnBannedAccountCheck(playerid);

//------------------------------------------------------------------------------

enum e_player_adata
{
    e_player_database_id,
    e_player_password[MAX_PLAYER_PASSWORD],
    e_player_regdate[32],
    e_player_email[64],
    e_player_ip[16],
    e_player_money,
    e_player_bank,
    e_player_gender,
    e_player_age,
    e_player_skin,
    bool:e_player_muted,
    e_player_warning,
    e_player_played_time,
    e_player_admin,
    e_player_lastlogin
}
static gPlayerAccountData[MAX_PLAYERS][e_player_adata];

//------------------------------------------------------------------------------

enum e_player_bdata
{
    bool:e_player_banned,
    e_player_badmin_name[MAX_PLAYER_NAME],
    e_player_created_at,
    e_player_expire,
    e_player_reason[255]
}
static gPlayerBannedData[MAX_PLAYERS][e_player_bdata];

//------------------------------------------------------------------------------

enum PlayerState (<<= 1)
{
    E_PLAYER_STATE_NONE,
    E_PLAYER_STATE_LOGGED = 1
}
static PlayerState:gPlayerStates[MAX_PLAYERS];

//------------------------------------------------------------------------------

SetPlayerLogged(playerid, bool:set)
{
    if(set)
        gPlayerStates[playerid] |= E_PLAYER_STATE_LOGGED;
    else
        gPlayerStates[playerid] &= ~E_PLAYER_STATE_LOGGED;
}

//------------------------------------------------------------------------------

IsPlayerLogged(playerid)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    if(gPlayerStates[playerid] & E_PLAYER_STATE_LOGGED)
        return 1;

    return 0;
}

//------------------------------------------------------------------------------

SavePlayerAccount(playerid)
{
    // Caso o jogador não estiver logado, terminar função
    if(!IsPlayerLogged(playerid))
        return 0;

    // Salvar conta
    new query[168];
	mysql_format(gMySQL, query, sizeof(query), "UPDATE `users` SET `ip`='%s', `skin`=%d, `admin`=%d, `last_login`=%d WHERE `id`=%d", gPlayerAccountData[playerid][e_player_ip], GetPlayerSkin(playerid), gPlayerAccountData[playerid][e_player_admin], gettime(), gPlayerAccountData[playerid][e_player_database_id]);
	mysql_pquery(gMySQL, query);
    mysql_format(gMySQL, query, sizeof(query), "UPDATE user_preferences SET color=%d, fight_style=%d, auto_repair=%d, name_tags=%d, goto=%d, drift=%d, drift_counter=%d WHERE user_id=%d",
    GetPlayerColor(playerid), GetPlayerFightingStyle(playerid), GetPlayerAutoRepairState(playerid), GetPlayerNameTagsState(playerid), GetPlayerGotoState(playerid), GetPlayerDriftState(playerid), GetPlayerDriftCounter(playerid), gPlayerAccountData[playerid][e_player_database_id]);
	mysql_pquery(gMySQL, query);
    return 1;
}

//------------------------------------------------------------------------------

ResetPlayerData(playerid)
{
    new ct = gettime();

    gPlayerStates[playerid] = E_PLAYER_STATE_NONE;

    gPlayerAccountData[playerid][e_player_database_id]  = 0;
    gPlayerAccountData[playerid][e_player_regdate][0]   = '\0';
    gPlayerAccountData[playerid][e_player_lastlogin]    = ct;
}

//------------------------------------------------------------------------------

LoadPlayerAccount(playerid)
{
    new query[106 + MAX_PLAYER_NAME], playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    mysql_format(gMySQL, query, sizeof(query),"SELECT * FROM users LEFT JOIN user_preferences ON users.id=user_preferences.user_id WHERE username = '%e'", playerName);
    mysql_tquery(gMySQL, query, "OnAccountLoad", "i", playerid);
}

//------------------------------------------------------------------------------

hook OnPlayerConnect(playerid)
{
    ClearPlayerScreen(playerid);
    SetPlayerColor(playerid, 0xACACACFF);
    SendClientMessage(playerid, 0xA9C4E4FF, "Conectado ao banco de dados, por favor, aguarde...");

    // Verifica se o jogador está banido e prossegue com a checagem da conta
    new query[128], playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    mysql_format(gMySQL, query, 128, "SELECT * FROM `bans` WHERE `username` = '%e' LIMIT 1", playerName);
    mysql_tquery(gMySQL, query, "OnBannedAccountCheck", "i", playerid);
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerRequestClass(playerid, classid)
{
    if(!IsPlayerLogged(playerid))
    {
        // Camera sobrevoando cidade enquanto faz login
        TogglePlayerSpectating(playerid, true);
        InterpolateCameraPos(playerid, 1080.0939, -1013.4362, 208.6180, 1180.0939, -1113.4362, 203.6180, 30000, CAMERA_MOVE);
        InterpolateCameraLookAt(playerid, 1333.0903, -1205.6227, 203.4406, 1333.0903, -1205.6227, 197.4406, 30000, CAMERA_MOVE);
        return -1;
    }
    SetSpawnInfo(playerid, 255, gPlayerAccountData[playerid][e_player_skin], 2234.6855, -1260.9462, 23.9329, 270.0490, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerRequestSpawn(playerid)
{
    if(!IsPlayerLogged(playerid))
    {
        PlayErrorSound(playerid);
        SendClientMessage(playerid, COLOR_ERROR, "* Você não está logado.");
        return -1;
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    SavePlayerAccount(playerid);
    SetPlayerLogged(playerid, false);
    ResetPlayerData(playerid);
    return 1;
}

//------------------------------------------------------------------------------

public OnAccountCheck(playerid)
{
	new rows, fields, playerName[MAX_PLAYER_NAME];
	cache_get_data(rows, fields, gMySQL);
    GetPlayerName(playerid, playerName, sizeof(playerName));
	if(rows)
	{
        if(gPlayerBannedData[playerid][e_player_banned] && (gPlayerBannedData[playerid][e_player_expire] < 0 || gPlayerBannedData[playerid][e_player_expire] > gettime()))
        {
            new info[564];
            format(info, sizeof(info), "{ffffff}%s, esta conta está banida!\n\nData do banimento: {fe9ddd}%s.\n{ffffff}Autor do banimento: {fe9ddd}%s.\n{ffffff}Expiração do banimento: {fe9ddd}%s\n{ffffff}Motivo do banimento:\n{fe9ddd}%s",
            playerName, convertTimestamp(gPlayerBannedData[playerid][e_player_created_at]), gPlayerBannedData[playerid][e_player_badmin_name],
            (gPlayerBannedData[playerid][e_player_expire] > 0) ? convertTimestamp(gPlayerBannedData[playerid][e_player_expire]) : "Nunca", gPlayerBannedData[playerid][e_player_reason]);
            ShowPlayerDialog(playerid, DIALOG_BANNED, DIALOG_STYLE_MSGBOX, "Banido", info, "Sair", "");
            PlayErrorSound(playerid);
        }
        else
        {
            cache_get_field_content(0, "password", gPlayerAccountData[playerid][e_player_password], gMySQL, MAX_PLAYER_PASSWORD);
            gPlayerAccountData[playerid][e_player_database_id]  = cache_get_field_content_int(0, "id", gMySQL);
            gPlayerAccountData[playerid][e_player_skin]         = cache_get_field_content_int(0, "skin", gMySQL);

            /*
            new info[104];
            format(info, sizeof(info), "Bem-vindo de volta, %s!\n\nVocê já possui uma conta.\nDigite sua senha para acessar.", playerName);
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Acesso", info, "Accessar", "Sair");
            PlaySelectSound(playerid);
            */
            ShowPlayerAuthentication(playerid, true);

            // Caso o banimento do jogador expirar, deletar da tabela de bans
            if(gPlayerBannedData[playerid][e_player_banned])
            {
                new query[57 + MAX_PLAYER_NAME + 1];
                mysql_format(gMySQL, query, sizeof(query),"DELETE FROM `bans` WHERE `username` = '%s'", playerName);
                mysql_tquery(gMySQL, query);
            }
        }
	}
    else
    {
        /*
        new info[102];
        format(info, sizeof(info), "Bem-vindo, %s!\n\nVocê não possui uma conta.\nDigite uma senha para cadastrar.", playerName);
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Cadastro", info, "Cadastrar", "Sair");
        PlaySelectSound(playerid);
        */
        ShowPlayerAuthentication(playerid, false);
    }
    return 1;
}

//------------------------------------------------------------------------------

public OnNameCheck(playerid, name[])
{
	new rows, fields, playerName[MAX_PLAYER_NAME];
	cache_get_data(rows, fields, gMySQL);
    GetPlayerName(playerid, playerName, sizeof(playerName));
	if(rows)
	{
        SendClientMessage(playerid, COLOR_ERROR, "* Este nome já está em uso.");
        PlayErrorSound(playerid);
	}
    else
    {
        new tempName[MAX_PLAYER_NAME], oldName[MAX_PLAYER_NAME];
        valstr(tempName, gettime());
        GetPlayerName(playerid, oldName, sizeof(oldName));
        SetPlayerName(playerid, tempName);
        switch(SetPlayerName(playerid, name))
        {
            case -1:
            {
                PlayErrorSound(playerid);
                SendClientMessage(playerid, COLOR_ERROR, "* Nome muito longo ou possui characteres inválidos.");
                SetPlayerName(playerid, oldName);
                return 1;
            }
            case 1:
            {
                SendClientMessage(playerid, COLOR_SUCCESS, "* Nome alterado com sucesso.");
                PlayConfirmSound(playerid);
            }
        }

        new query[128];
    	mysql_format(gMySQL, query, sizeof(query), "UPDATE `users` SET `username`='%s' WHERE `id`=%d", name, gPlayerAccountData[playerid][e_player_database_id]);
    	mysql_pquery(gMySQL, query);
    }
    return 1;
}

//------------------------------------------------------------------------------

public OnEmailCheck(playerid, email[])
{
	new rows, fields, playerName[MAX_PLAYER_NAME];
	cache_get_data(rows, fields, gMySQL);
    GetPlayerName(playerid, playerName, sizeof(playerName));
	if(rows)
	{
        SendClientMessage(playerid, COLOR_ERROR, "* Este email já está em uso.");
        PlayErrorSound(playerid);
	}
    else
    {
        SetPlayerEmail(playerid, email);
        PlayConfirmSound(playerid);
    }
    return 1;
}

//------------------------------------------------------------------------------

public OnBannedAccountCheck(playerid)
{
	new rows, fields, playerName[MAX_PLAYER_NAME];
	cache_get_data(rows, fields, gMySQL);
    GetPlayerName(playerid, playerName, sizeof(playerName));
	if(rows)
	{
        gPlayerBannedData[playerid][e_player_banned]                = true;
        gPlayerBannedData[playerid][e_player_created_at]            = cache_get_field_content_int(0, "created_at", gMySQL);
        gPlayerBannedData[playerid][e_player_expire]                = cache_get_field_content_int(0, "expire", gMySQL);
        cache_get_field_content(0, "admin", gPlayerBannedData[playerid][e_player_badmin_name], gMySQL, MAX_PLAYER_NAME);
        cache_get_field_content(0, "reason", gPlayerBannedData[playerid][e_player_reason], gMySQL, 255);
	}
    else
    {
        gPlayerBannedData[playerid][e_player_banned]   = false;
    }

    // Após checagem se a conta está banida, prosseguir com o carregamento normalmente.
    new query[57 + MAX_PLAYER_NAME + 1];
    mysql_format(gMySQL, query, sizeof(query),"SELECT * FROM `users` WHERE `username` = '%e' LIMIT 1", playerName);
    mysql_tquery(gMySQL, query, "OnAccountCheck", "i", playerid);
    return 1;
}

//------------------------------------------------------------------------------

public OnAccountRegister(playerid)
{
    gPlayerAccountData[playerid][e_player_database_id] = cache_insert_id();

    new query[64];
    mysql_format(gMySQL, query, sizeof(query), "INSERT INTO user_preferences (user_id) VALUES (%d)", gPlayerAccountData[playerid][e_player_database_id]);
    mysql_tquery(gMySQL, query);

    SetSpawnInfo(playerid, 255, 0, 2234.6855, -1260.9462, 23.9329, 270.0490, 0, 0, 0, 0, 0, 0);
    TogglePlayerSpectating(playerid, false);
    ShowPlayerLobby(playerid);

    new playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
	printf("[mysql] new player account registered on database. ID: %d, Username: %s", gPlayerAccountData[playerid][e_player_database_id], playerName);
	return 1;
}

//------------------------------------------------------------------------------

public OnAccountLoad(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields, gMySQL);
	if(rows)
	{
        GetPlayerIp(playerid, gPlayerAccountData[playerid][e_player_ip], 16);
        gPlayerAccountData[playerid][e_player_database_id]  = cache_get_field_content_int(0, "id", gMySQL);
        gPlayerAccountData[playerid][e_player_skin]         = cache_get_field_content_int(0, "skin", gMySQL);
        gPlayerAccountData[playerid][e_player_admin]        = cache_get_field_content_int(0, "admin", gMySQL);
        gPlayerAccountData[playerid][e_player_lastlogin]    = cache_get_field_content_int(0, "last_login", gMySQL);
        cache_get_field_content(0, "created_at", gPlayerAccountData[playerid][e_player_regdate], gMySQL, 32);

        SetSpawnInfo(playerid, 255, gPlayerAccountData[playerid][e_player_skin], 2234.6855, -1260.9462, 23.9329, 270.0490, 0, 0, 0, 0, 0, 0);
        TogglePlayerSpectating(playerid, false);
        ShowPlayerLobby(playerid);

        // Load player preferences
        SetPlayerColor(playerid,            cache_get_field_content_int(0, "color", gMySQL));
        TogglePlayerAutoRepair(playerid,    cache_get_field_content_int(0, "auto_repair", gMySQL));
        TogglePlayerGoto(playerid,          cache_get_field_content_int(0, "goto", gMySQL));
        TogglePlayerNameTags(playerid,      cache_get_field_content_int(0, "name_tags", gMySQL));
        TogglePlayerDrift(playerid,         cache_get_field_content_int(0, "drift", gMySQL));
        TogglePlayerDriftCounter(playerid,  cache_get_field_content_int(0, "drift_counter", gMySQL));
        SetPlayerFightingStyle(playerid,    cache_get_field_content_int(0, "fight_style", gMySQL));
        SetPlayerLogged(playerid, true);
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_LOGIN:
        {
            if(!response)
                return Kick(playerid);

            if(!strcmp(gPlayerAccountData[playerid][e_player_password], inputtext) && !isnull(gPlayerAccountData[playerid][e_player_password]) && !isnull(inputtext))
            {
                PlayConfirmSound(playerid);
                LoadPlayerAccount(playerid);
                SendClientMessage(playerid, 0x88AA62FF, "Conectado.");
            }
            else
            {
                ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Acessar->Senha incorreta", "Senha incorreta!\nTente novamente:", "Acessar", "Sair"),
                PlayErrorSound(playerid);
            }
            return -2;
        }
        case DIALOG_REGISTER:
        {
            if(!response)
                Kick(playerid);
            else if(strlen(inputtext) < 6)
                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Cadastrar->Senha muito curta", "Tente novamente:", "Cadastrar", "Sair"),
                PlayErrorSound(playerid);
            else if(strlen(inputtext) > MAX_PLAYER_PASSWORD-1)
                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Cadastrar->Senha muito longa", "Tente novamente:", "Cadastrar", "Sair"),
                PlayErrorSound(playerid);
            else
            {
                PlayConfirmSound(playerid);
                SetPlayerLogged(playerid, true);
                SendClientMessage(playerid, 0x88AA62FF, "Cadastrado.");

                new playerIP[16], playerName[MAX_PLAYER_NAME];
                GetPlayerName(playerid, playerName, sizeof(playerName));
                GetPlayerIp(playerid, playerIP, sizeof(playerIP));

                new query[128];
                mysql_format(gMySQL, query, sizeof(query), "INSERT INTO `users` (`username`, `password`, `ip`, `created_at`) VALUES ('%e', '%e', '%s', now())", playerName, inputtext, playerIP);
            	mysql_tquery(gMySQL, query, "OnAccountRegister", "i", playerid);
            }
            return -2;
        }
        case DIALOG_BANNED:
        {
            Kick(playerid);
            return -2;
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

GetPlayerDatabaseID(playerid)
{
    return gPlayerAccountData[playerid][e_player_database_id];
}

GetPlayerBankCash(playerid)
{
    return gPlayerAccountData[playerid][e_player_bank];
}

SetPlayerBankCash(playerid, value)
{
    gPlayerAccountData[playerid][e_player_bank] = value;
}

GetPlayerCash(playerid)
{
    return gPlayerAccountData[playerid][e_player_money];
}

SetPlayerCash(playerid, value)
{
    ResetPlayerMoney(playerid);
    gPlayerAccountData[playerid][e_player_money] = value;
    GivePlayerMoney(playerid, value);
}

GivePlayerCash(playerid, value)
{
    ResetPlayerMoney(playerid);
    gPlayerAccountData[playerid][e_player_money] += value;
    GivePlayerMoney(playerid, gPlayerAccountData[playerid][e_player_money]);
}

GetPlayerPlayedTime(playerid)
{
    return gPlayerAccountData[playerid][e_player_played_time];
}

SetPlayerPlayedTime(playerid, value)
{
    gPlayerAccountData[playerid][e_player_played_time] = value;
}

GetPlayerAdminLevel(playerid)
{
    return gPlayerAccountData[playerid][e_player_admin];
}

SetPlayerAdminLevel(playerid, value)
{
    gPlayerAccountData[playerid][e_player_admin] = value;
}

IsPlayerMuted(playerid)
{
    return gPlayerAccountData[playerid][e_player_muted];
}

TogglePlayerMute(playerid, bool:value)
{
    gPlayerAccountData[playerid][e_player_muted] = value;
}

GetPlayerWarning(playerid)
{
    return gPlayerAccountData[playerid][e_player_warning];
}

SetPlayerWarning(playerid, value)
{
    gPlayerAccountData[playerid][e_player_warning] = value;
}

GetPlayerGender(playerid)
{
    return gPlayerAccountData[playerid][e_player_gender];
}

SetPlayerGender(playerid, value)
{
    gPlayerAccountData[playerid][e_player_gender] = value;
}

GetPlayerLastLogin(playerid)
{
    return gPlayerAccountData[playerid][e_player_lastlogin];
}

SetPlayerEmail(playerid, email[])
{
    format(gPlayerAccountData[playerid][e_player_email], 64, email);
}

GetPlayerEmail(playerid)
{
    new email[MAX_PLAYER_PASSWORD];
    strcat(email, gPlayerAccountData[playerid][e_player_email]);
    return email;
}

SetPlayerAge(playerid, age)
{
    gPlayerAccountData[playerid][e_player_age] = age;
}

GetPlayerSaveSkin(playerid)
{
    return gPlayerAccountData[playerid][e_player_skin];
}

GetPlayerAge(playerid)
{
    return gPlayerAccountData[playerid][e_player_age];
}

GetPlayerPassword(playerid)
{
    new password[MAX_PLAYER_PASSWORD];
    strcat(password, gPlayerAccountData[playerid][e_player_password]);
    return password;
}

SetPlayerPassword(playerid, password[], update=true)
{
    format(gPlayerAccountData[playerid][e_player_password], MAX_PLAYER_PASSWORD, password);

    if(update)
    {
        new query[128];
    	mysql_format(gMySQL, query, sizeof(query), "UPDATE `users` SET `password`='%s' WHERE `id`=%d", gPlayerAccountData[playerid][e_player_password], gPlayerAccountData[playerid][e_player_database_id]);
    	mysql_pquery(gMySQL, query);
    }
}

ChangePlayerName(playerid, name[])
{
    new query[57 + MAX_PLAYER_NAME + 1];
    mysql_format(gMySQL, query, sizeof(query),"SELECT * FROM `users` WHERE `username` = '%e' LIMIT 1", name);
    mysql_tquery(gMySQL, query, "OnNameCheck", "is", playerid, name);
    return 1;
}

//------------------------------------------------------------------------------
