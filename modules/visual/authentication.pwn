/*******************************************************************************
* NOME DO ARQUIVO :		modules/visual/authentication.pwn
*
* DESCRIÇÃO :
*	   Script responsável por mostrar e ocultar a UI de autenticação.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

static Text:registerTextDraw[9];
static Text:backgroundTextDraw[7];

static bool:isTextDrawVisible[MAX_PLAYERS];
static bool:isPlayerRegistered[MAX_PLAYERS];

//------------------------------------------------------------------------------

ShowPlayerAuthentication(playerid, bool:login)
{
    PlayAudioStreamForPlayer(playerid, "http://live.hunterfm.com/live");
    ClearPlayerScreen(playerid);

    if(login)
    {

    }
    else
    {
        ShowPlayerRegisterTextDraw(playerid);
        SelectTextDraw(playerid, 0xdd770dff);
    }
}

//------------------------------------------------------------------------------

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == Text:INVALID_TEXT_DRAW)
    {
         if(isTextDrawVisible[playerid])
         {
             SelectTextDraw(playerid, 0xdd770dff);
         }
    }
    else if(clickedid == registerTextDraw[2])
    {
         ShowPlayerDialog(playerid, DIALOG_REGISTER_GENDER, DIALOG_STYLE_MSGBOX, "Cadastro: Sexo", "Informe seu sexo", "Masculino", "Feminino");
    }
    else if(clickedid == registerTextDraw[3])
    {
         ShowPlayerDialog(playerid, DIALOG_REGISTER_PASSWORD, DIALOG_STYLE_PASSWORD, "Cadastro: Senha", "Informe sua senha", "Salvar", "Voltar");
    }
    else if(clickedid == registerTextDraw[4])
    {
        new output[290];
        for(new i = 10; i < 100; i++)
        {
            new string[6];
            format(string, sizeof(string), "%i\n", i);
            strcat(output, string);
        }
        ShowPlayerDialog(playerid, DIALOG_REGISTER_AGE, DIALOG_STYLE_LIST, "Cadastro: Idade", output, "Salvar", "Voltar");
    }
    else if(clickedid == registerTextDraw[5])
    {
         ShowPlayerDialog(playerid, DIALOG_REGISTER_EMAIL, DIALOG_STYLE_INPUT, "Cadastro: Email", "Insira seu e-mail", "Salvar", "Voltar");
    }
    else if(clickedid == registerTextDraw[6])
    {
        if(strlen(GetPlayerPassword(playerid)) < 4 || strlen(GetPlayerEmail(playerid)) < 4 || GetPlayerAge(playerid) < 10 || GetPlayerGender(playerid) == -1)
        {
            ShowPlayerRegisterTextDrawErr(playerid);
            PlayErrorSound(playerid);
        }
        else
        {
            StopAudioStreamForPlayer(playerid);
            PlayConfirmSound(playerid);
            SetPlayerLogged(playerid, true);
            SendClientMessage(playerid, 0x88AA62FF, "Cadastrado.");
            HidePlayerRegisterTextDraw(playerid);

            new playerIP[16], playerName[MAX_PLAYER_NAME];
            GetPlayerName(playerid, playerName, sizeof(playerName));
            GetPlayerIp(playerid, playerIP, sizeof(playerIP));

            new query[256];
            mysql_format(gMySQL, query, sizeof(query), "INSERT INTO `users` (`username`, `email`, `password`, `ip`, `created_at`) VALUES ('%e', '%e', '%e', '%s', now())", playerName, GetPlayerEmail(playerid), GetPlayerPassword(playerid), playerIP);
            mysql_tquery(gMySQL, query, "OnAccountRegister", "i", playerid);
        }
    }
    else if(clickedid == registerTextDraw[7])
    {
        Kick(playerid);
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_REGISTER_GENDER:
        {
            if(!response)
            {
                SetPlayerGender(playerid, 1);
                PlayConfirmSound(playerid);
            }
            else
            {
                SetPlayerGender(playerid, 0);
                PlayConfirmSound(playerid);
            }
        }
        case DIALOG_REGISTER_PASSWORD:
        {
            if(!response)
                PlayCancelSound(playerid);
            else if(strlen(inputtext) < 4)
            {
                PlayErrorSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_REGISTER_PASSWORD, DIALOG_STYLE_PASSWORD, "Cadastro: Senha", "Informe sua senha\n{ff0000}Senha muito curta!", "Salvar", "Voltar");
            }
            else if(strlen(inputtext) > MAX_PLAYER_PASSWORD-1)
            {
                PlayErrorSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_REGISTER_PASSWORD, DIALOG_STYLE_PASSWORD, "Cadastro: Senha", "Informe sua senha\n{ff0000}Senha muito longa!", "Salvar", "Voltar");
            }
            else
            {
                SetPlayerPassword(playerid, inputtext, false);
                PlayConfirmSound(playerid);
            }
        }
        case DIALOG_REGISTER_AGE:
        {
            if(!response)
                PlayCancelSound(playerid);
            else
            {
                SetPlayerAge(playerid, (listitem + 10));
                PlayConfirmSound(playerid);
            }
        }
        case DIALOG_REGISTER_EMAIL:
        {
            if(!response)
                PlayCancelSound(playerid);
            else if(strlen(inputtext) < 4)
            {
                PlayErrorSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_REGISTER_EMAIL, DIALOG_STYLE_INPUT, "Cadastro: Email", "Insira seu e-mail\n{ff0000}Email inválido!", "Salvar", "Voltar");
            }
            else
            {
                new query[128];
                mysql_format(gMySQL, query, sizeof(query),"SELECT * FROM `users` WHERE `email` = '%e' LIMIT 1", inputtext);
                mysql_tquery(gMySQL, query, "OnEmailCheck", "is", playerid, inputtext);
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

ShowPlayerRegisterTextDraw(playerid)
{
    for(new i = 0; i < sizeof(backgroundTextDraw); i++)
        TextDrawShowForPlayer(playerid, backgroundTextDraw[i]);

    for(new i = 0; i < (sizeof(registerTextDraw) - 1); i++)
        TextDrawShowForPlayer(playerid, registerTextDraw[i]);
}

//------------------------------------------------------------------------------

HidePlayerRegisterTextDraw(playerid)
{
    for(new i = 0; i < sizeof(backgroundTextDraw); i++)
        TextDrawHideForPlayer(playerid, backgroundTextDraw[i]);

    for(new i = 0; i < sizeof(registerTextDraw); i++)
        TextDrawHideForPlayer(playerid, registerTextDraw[i]);

    CancelSelectTextDraw(playerid);
}

//------------------------------------------------------------------------------

ShowPlayerRegisterTextDrawErr(playerid)
{
    TextDrawShowForPlayer(playerid, registerTextDraw[8]);
}

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    isTextDrawVisible[playerid] = false;
    isPlayerRegistered[playerid] = false;
    return 1;
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    backgroundTextDraw[0] = TextDrawCreate(197.000000, 2.000000, "#"); // box total
    TextDrawBackgroundColor(backgroundTextDraw[0], 255);
    TextDrawFont(backgroundTextDraw[0], 2);
    TextDrawLetterSize(backgroundTextDraw[0], 0.500000, 49.499992);
    TextDrawColor(backgroundTextDraw[0], -1);
    TextDrawSetOutline(backgroundTextDraw[0], 0);
    TextDrawSetProportional(backgroundTextDraw[0], 1);
    TextDrawSetShadow(backgroundTextDraw[0], 1);
    TextDrawUseBox(backgroundTextDraw[0], 1);
    TextDrawBoxColor(backgroundTextDraw[0], 136);
    TextDrawTextSize(backgroundTextDraw[0], 442.000000, -21.000000);
    TextDrawSetSelectable(backgroundTextDraw[0], 0);

    backgroundTextDraw[1] = TextDrawCreate(230.000000, 13.000000, "~b~~h~B~w~rothers ~r~in ~g~~h~G~w~ame"); // logo
    TextDrawBackgroundColor(backgroundTextDraw[1], 255);
    TextDrawFont(backgroundTextDraw[1], 1);
    TextDrawLetterSize(backgroundTextDraw[1], 0.600000, 2.900000);
    TextDrawColor(backgroundTextDraw[1], -1);
    TextDrawSetOutline(backgroundTextDraw[1], 0);
    TextDrawSetProportional(backgroundTextDraw[1], 1);
    TextDrawSetShadow(backgroundTextDraw[1], 1);
    TextDrawSetSelectable(backgroundTextDraw[1], 0);

    backgroundTextDraw[2] = TextDrawCreate(250.000000, 38.000000, "~w~-"); // linha embaixo do logo
    TextDrawBackgroundColor(backgroundTextDraw[2], 255);
    TextDrawFont(backgroundTextDraw[2], 1);
    TextDrawLetterSize(backgroundTextDraw[2], 9.510000, 1.000000);
    TextDrawColor(backgroundTextDraw[2], -1);
    TextDrawSetOutline(backgroundTextDraw[2], 0);
    TextDrawSetProportional(backgroundTextDraw[2], 1);
    TextDrawSetShadow(backgroundTextDraw[2], 1);
    TextDrawSetSelectable(backgroundTextDraw[2], 0);

    backgroundTextDraw[3] = TextDrawCreate(197.000000, 97.000000, "#"); // barra de cima
    TextDrawBackgroundColor(backgroundTextDraw[3], 255);
    TextDrawFont(backgroundTextDraw[3], 2);
    TextDrawLetterSize(backgroundTextDraw[3], 0.610000, 0.199999);
    TextDrawColor(backgroundTextDraw[3], -1);
    TextDrawSetOutline(backgroundTextDraw[3], 0);
    TextDrawSetProportional(backgroundTextDraw[3], 1);
    TextDrawSetShadow(backgroundTextDraw[3], 1);
    TextDrawUseBox(backgroundTextDraw[3], 1);
    TextDrawBoxColor(backgroundTextDraw[3], 255);
    TextDrawTextSize(backgroundTextDraw[3], 442.000000, -20.000000);
    TextDrawSetSelectable(backgroundTextDraw[3], 0);

    backgroundTextDraw[4] = TextDrawCreate(240.000000, 370.000000, "Desejamos um bom jogo !");
    TextDrawBackgroundColor(backgroundTextDraw[4], 255);
    TextDrawFont(backgroundTextDraw[4], 2);
    TextDrawLetterSize(backgroundTextDraw[4], 0.290000, 1.000000);
    TextDrawColor(backgroundTextDraw[4], -1);
    TextDrawSetOutline(backgroundTextDraw[4], 1);
    TextDrawSetProportional(backgroundTextDraw[4], 1);
    TextDrawSetSelectable(backgroundTextDraw[4], 0);

    backgroundTextDraw[5] = TextDrawCreate(193.000000, 2.000000, "#"); // barra esquerda
    TextDrawBackgroundColor(backgroundTextDraw[5], 255);
    TextDrawFont(backgroundTextDraw[5], 2);
    TextDrawLetterSize(backgroundTextDraw[5], 0.610000, 51.099998);
    TextDrawColor(backgroundTextDraw[5], -1);
    TextDrawSetOutline(backgroundTextDraw[5], 0);
    TextDrawSetProportional(backgroundTextDraw[5], 1);
    TextDrawSetShadow(backgroundTextDraw[5], 1);
    TextDrawUseBox(backgroundTextDraw[5], 1);
    TextDrawBoxColor(backgroundTextDraw[5], 255);
    TextDrawTextSize(backgroundTextDraw[5], 194.000000, -20.000000);
    TextDrawSetSelectable(backgroundTextDraw[5], 0);

    backgroundTextDraw[6] = TextDrawCreate(446.000000, 2.000000, "#"); // barra direita
    TextDrawBackgroundColor(backgroundTextDraw[6], 255);
    TextDrawFont(backgroundTextDraw[6], 2);
    TextDrawLetterSize(backgroundTextDraw[6], 0.610000, 51.099998);
    TextDrawColor(backgroundTextDraw[6], -1);
    TextDrawSetOutline(backgroundTextDraw[6], 0);
    TextDrawSetProportional(backgroundTextDraw[6], 1);
    TextDrawSetShadow(backgroundTextDraw[6], 1);
    TextDrawUseBox(backgroundTextDraw[6], 1);
    TextDrawBoxColor(backgroundTextDraw[6], 255);
    TextDrawTextSize(backgroundTextDraw[6], 438.000000, -20.000000);
    TextDrawSetSelectable(backgroundTextDraw[6], 0);

    registerTextDraw[0] = TextDrawCreate(197.000000, 80.000000, "  Registro");
    TextDrawBackgroundColor(registerTextDraw[0], 255);
    TextDrawFont(registerTextDraw[0], 3);
    TextDrawLetterSize(registerTextDraw[0], 0.540000, 1.699998);
    TextDrawColor(registerTextDraw[0], -1);
    TextDrawSetOutline(registerTextDraw[0], 1);
    TextDrawSetProportional(registerTextDraw[0], 1);
    TextDrawUseBox(registerTextDraw[0], 1);
    TextDrawBoxColor(registerTextDraw[0], 255);
    TextDrawTextSize(registerTextDraw[0], 314.000000, 0.000000);
    TextDrawSetSelectable(registerTextDraw[0], 0);

    registerTextDraw[1] = TextDrawCreate(197.000000, 332.000000, "#"); // barra de baixo
    TextDrawBackgroundColor(registerTextDraw[1], 255);
    TextDrawFont(registerTextDraw[1], 2);
    TextDrawLetterSize(registerTextDraw[1], 0.610000, 0.199999);
    TextDrawColor(registerTextDraw[1], -1);
    TextDrawSetOutline(registerTextDraw[1], 0);
    TextDrawSetProportional(registerTextDraw[1], 1);
    TextDrawSetShadow(registerTextDraw[1], 1);
    TextDrawUseBox(registerTextDraw[1], 1);
    TextDrawBoxColor(registerTextDraw[1], 255);
    TextDrawTextSize(registerTextDraw[1], 442.000000, -20.000000);
    TextDrawSetSelectable(registerTextDraw[1], 0);

    registerTextDraw[2] = TextDrawCreate(235.000000, 139.000000, "       SEXO");
    TextDrawBackgroundColor(registerTextDraw[2], 255);
    TextDrawFont(registerTextDraw[2], 1);
    TextDrawLetterSize(registerTextDraw[2], 0.500000, 1.499999);
    TextDrawColor(registerTextDraw[2], -1);
    TextDrawSetOutline(registerTextDraw[2], 1);
    TextDrawSetProportional(registerTextDraw[2], 1);
    TextDrawUseBox(registerTextDraw[2], 1);
    TextDrawBoxColor(registerTextDraw[2], 102);
    TextDrawTextSize(registerTextDraw[2], 403.000000, 10.000000);
    TextDrawSetSelectable(registerTextDraw[2], true);

    registerTextDraw[3] = TextDrawCreate(235.000000, 184.000000, "       SENHA");
    TextDrawBackgroundColor(registerTextDraw[3], 255);
    TextDrawFont(registerTextDraw[3], 1);
    TextDrawLetterSize(registerTextDraw[3], 0.500000, 1.499999);
    TextDrawColor(registerTextDraw[3], -1);
    TextDrawSetOutline(registerTextDraw[3], 1);
    TextDrawSetProportional(registerTextDraw[3], 1);
    TextDrawUseBox(registerTextDraw[3], 1);
    TextDrawBoxColor(registerTextDraw[3], 102);
    TextDrawTextSize(registerTextDraw[3], 403.000000, 10.000000);
    TextDrawSetSelectable(registerTextDraw[3], true);

    registerTextDraw[4] = TextDrawCreate(235.000000, 230.000000, "       IDADE");
    TextDrawBackgroundColor(registerTextDraw[4], 255);
    TextDrawFont(registerTextDraw[4], 1);
    TextDrawLetterSize(registerTextDraw[4], 0.500000, 1.499999);
    TextDrawColor(registerTextDraw[4], -1);
    TextDrawSetOutline(registerTextDraw[4], 1);
    TextDrawSetProportional(registerTextDraw[4], 1);
    TextDrawUseBox(registerTextDraw[4], 1);
    TextDrawBoxColor(registerTextDraw[4], 102);
    TextDrawTextSize(registerTextDraw[4], 403.000000, 10.000000);
    TextDrawSetSelectable(registerTextDraw[4], true);

    registerTextDraw[5] = TextDrawCreate(235.000000, 276.000000, "       EMAIL");
    TextDrawBackgroundColor(registerTextDraw[5], 255);
    TextDrawFont(registerTextDraw[5], 1);
    TextDrawLetterSize(registerTextDraw[5], 0.500000, 1.499999);
    TextDrawColor(registerTextDraw[5], -1);
    TextDrawSetOutline(registerTextDraw[5], 1);
    TextDrawSetProportional(registerTextDraw[5], 1);
    TextDrawUseBox(registerTextDraw[5], 1);
    TextDrawBoxColor(registerTextDraw[5], 102);
    TextDrawTextSize(registerTextDraw[5], 403.000000, 10.000000);
    TextDrawSetSelectable(registerTextDraw[5], true);

    registerTextDraw[6] = TextDrawCreate(197.000000, 332.000000, "  Cadastrar");
    TextDrawBackgroundColor(registerTextDraw[6], 255);
    TextDrawFont(registerTextDraw[6], 3);
    TextDrawLetterSize(registerTextDraw[6], 0.540000, 1.699998);
    TextDrawColor(registerTextDraw[6], -1);
    TextDrawSetOutline(registerTextDraw[6], 1);
    TextDrawSetProportional(registerTextDraw[6], 1);
    TextDrawUseBox(registerTextDraw[6], 1);
    TextDrawBoxColor(registerTextDraw[6], 255);
    TextDrawTextSize(registerTextDraw[6], 287.000000, 10.000000);
    TextDrawSetSelectable(registerTextDraw[6], true);

    registerTextDraw[7] = TextDrawCreate(326.000000, 332.000000, "  Cancelar");
    TextDrawBackgroundColor(registerTextDraw[7], 255);
    TextDrawFont(registerTextDraw[7], 3);
    TextDrawLetterSize(registerTextDraw[7], 0.540000, 1.699998);
    TextDrawColor(registerTextDraw[7], -1);
    TextDrawSetOutline(registerTextDraw[7], 1);
    TextDrawSetProportional(registerTextDraw[7], 1);
    TextDrawUseBox(registerTextDraw[7], 1);
    TextDrawBoxColor(registerTextDraw[7], 255);
    TextDrawTextSize(registerTextDraw[7], 442.000000, 10.000000);
    TextDrawSetSelectable(registerTextDraw[7], true);

    registerTextDraw[8] = TextDrawCreate(210.000000, 309.000000, "Por Favor preencha todos os dados !");
    TextDrawBackgroundColor(registerTextDraw[8], 255);
    TextDrawFont(registerTextDraw[8], 2);
    TextDrawLetterSize(registerTextDraw[8], 0.250000, 1.000000);
    TextDrawColor(registerTextDraw[8], -16776961);
    TextDrawSetOutline(registerTextDraw[8], 1);
    TextDrawSetProportional(registerTextDraw[8], 1);
    TextDrawSetSelectable(registerTextDraw[8], 0);
    return 1;
}
