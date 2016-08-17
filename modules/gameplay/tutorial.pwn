/*******************************************************************************
* NOME DO ARQUIVO :        modules/gameplay/tutorial.pwn
*
* DESCRIÇÃO :
*       Mostra o tutorial para novos jogadores.
*
* NOTAS :
*       -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

static bool:gIsPlayerInTutorial[MAX_PLAYERS];
static gPlayerTutorialStep[MAX_PLAYERS];

//------------------------------------------------------------------------------

static const gTutorialText[][][] =
{
    {
        "Bem-Vindo",
        "Olá, bem vindo ao Liberty Freeroam!~n~~n~Você irá agora passar \
        por um tutorial que irá lhe explicar algumas das possibilidades que você \
        pode fazer em nosso servidor.~n~~n~Esperamos que você se divirta bastante aqui \
        como nós nos divertimos construindo-o!~n~~n~Quaisquer dúvidas utilize o comando \
        /admins para falar com um administrador."},
    {
        "Lobby",
        "Nosso servidor possui vários modos de jogos diferentes, sendo eles:~n~~n~\
        | Freeroam~n~| Mata-mata~n~| Corrida~n~| Derby~n~~n~Para acessar os modos \
        de jogo utilize o comando /lobby.~n~Para sair de um modo de jogo utilize \
        o comando /lobby também!"
    },
    {
        "Corridas",
        "O modo de jogo de corridas possui diversas corridas para você experimentar.\
        ~n~~n~Neste modo de jogo você recebe um veículo e enfrente outros jogadores em alta velocidade \
        para descobrir quem é o melhor atrás do volante.~n~~n~Ao terminar a corrida você será enviado a sala novamente para correr de novo.~n~~n~\
        Caso você desejar ir outra corrida ou modo de jogo utilize o comando /lobby."
    },
    {
        "Mata-Mata",
        "No mata-mata seu objetivo é matar o maior número de jogadores para vencer a partida \
        caso você cometa suicídio você perderá 1 abate.~n~~n~O jogador que atingir o limite definido vence a partida!"
    },
    {
        "Derby",
        "Derby é onde os jogadores recebem veículos e devem derrubar outros jogadores da plataforma para vencer,\
        o ultimo jogador será o vencedor.~n~~n~Caso você saia do veículo ou ele exploda, você será desclassificado também."
    },
    {
        "Freeroam",
        "Aqui é onde tudo é permitido!~n~~n~Você pode saltar de paraquedas, manobras \
        radicais, mergulhos, drift, explorar montanhas, cidades, dar umas bebidas \
        no bar, comprar roupas e acessórios... enfim!~n~~n~A imaginação é o limite!"
    },
    {
        "Regras",
        "Nosso servidor possui regras pre-definidas para que todos possamos ter um bom convivio em pról da comunidade.~n~~n~\
        | Não é permitido o uso de qualquer tipo de cheats~n~\
        | Não é permitido fazer spam/flood~n~\
        | Não é permitido desrespeitar outros jogadores~n~\
        | Não é permitido divulgar outros servidores"
    },
    {
        "Considerações finais",
        "Agradecemos sua participação justa em nosso servidor, esperamos que você \
        tenha muitas horas de divertimento!~n~~n~Encontramos você por aí!"
    }

};

static Float:gTutorialCameras[][] =
{
    {0.0, 0.0, 1160.6168, -1647.9303, 48.0613, 1159.7582, -1647.4125, 47.4964},
    {0.0, 0.0, -1547.3136, 147.4965, 233.6728, -1548.0375, 146.8079, 227.9120},
    {7.0, 0.0, -1289.0591, -101.9945, 1073.6915, -1289.7101, -102.7518, 1073.3661},
    {0.0, 0.0, -2438.4839, 1548.2484, 11.7867, -2437.4902, 1548.2019, 11.4309},
    {0.0, 3000.0, 2827.3196, -3137.8960, 152.8835, 2828.2671, -3138.2141, 152.2936},
    {14.0, 0.0, -1501.9048, 1580.8624, 1079.7107, -1500.9312, 1581.0876, 1079.4043},
    {10.0, 0.0, 241.4963, 112.6989, 1003.8539, 240.4985, 112.7370, 1003.9284},
    {0.0, 0.0, -2287.1135, 1755.7581, 74.4123, -2288.1118, 1755.7615, 74.5221}
};

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    gIsPlayerInTutorial[playerid] = false;
    gPlayerTutorialStep[playerid] = 0;
    return 1;
}

//------------------------------------------------------------------------------

public OnPlayerClickTutorial(playerid, bool:direction)
{
    /*
    * Direction
    *   0 - left
    *   1 - right
    */
    if(!direction)
    {
        if(gPlayerTutorialStep[playerid] > 0)
        {
            PlaySelectSound(playerid);
            gPlayerTutorialStep[playerid]--;
            SetPlayerTutorialText(playerid, ConvertToGameText(gTutorialText[gPlayerTutorialStep[playerid]][0]), ConvertToGameText(gTutorialText[gPlayerTutorialStep[playerid]][1]));

            SetPlayerInterior(playerid, floatround(gTutorialCameras[gPlayerTutorialStep[playerid]][0]));
            SetPlayerVirtualWorld(playerid, floatround(gTutorialCameras[gPlayerTutorialStep[playerid]][1]));
            SetPlayerCameraPos(playerid, gTutorialCameras[gPlayerTutorialStep[playerid]][2], gTutorialCameras[gPlayerTutorialStep[playerid]][3], gTutorialCameras[gPlayerTutorialStep[playerid]][4]);
            SetPlayerCameraLookAt(playerid, gTutorialCameras[gPlayerTutorialStep[playerid]][5], gTutorialCameras[gPlayerTutorialStep[playerid]][6], gTutorialCameras[gPlayerTutorialStep[playerid]][7]);
        }
        else
        {
            PlayErrorSound(playerid);
        }
    }
    else
    {
        if(gPlayerTutorialStep[playerid] < sizeof(gTutorialText) - 1)
        {
            PlaySelectSound(playerid);
            gPlayerTutorialStep[playerid]++;
            SetPlayerTutorialText(playerid, ConvertToGameText(gTutorialText[gPlayerTutorialStep[playerid]][0]), ConvertToGameText(gTutorialText[gPlayerTutorialStep[playerid]][1]));

            SetPlayerInterior(playerid, floatround(gTutorialCameras[gPlayerTutorialStep[playerid]][0]));
            SetPlayerVirtualWorld(playerid, floatround(gTutorialCameras[gPlayerTutorialStep[playerid]][1]));
            SetPlayerCameraPos(playerid, gTutorialCameras[gPlayerTutorialStep[playerid]][2], gTutorialCameras[gPlayerTutorialStep[playerid]][3], gTutorialCameras[gPlayerTutorialStep[playerid]][4]);
            SetPlayerCameraLookAt(playerid, gTutorialCameras[gPlayerTutorialStep[playerid]][5], gTutorialCameras[gPlayerTutorialStep[playerid]][6], gTutorialCameras[gPlayerTutorialStep[playerid]][7]);
        }
        else
        {
            PlayerPlaySound(playerid, 1188, 0.0, 0.0, 0.0);
            gIsPlayerInTutorial[playerid] = false;
            HidePlayerTutorialText(playerid);
            TogglePlayerSpectating(playerid, false);
            ShowPlayerLobby(playerid);
            SetPlayerTutorial(playerid, true);
        }
    }
}

//------------------------------------------------------------------------------

SendPlayerToTutorial(playerid)
{
    ClearPlayerScreen(playerid);
    PlayerPlaySound(playerid, 1187, 0.0, 0.0, 0.0);
    gIsPlayerInTutorial[playerid] = true;
    gPlayerTutorialStep[playerid] = 0;
    SetPlayerTutorialText(playerid, ConvertToGameText(gTutorialText[0][0]), ConvertToGameText(gTutorialText[0][1]));
    ShowPlayerTutorialText(playerid);

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);

    TogglePlayerSpectating(playerid, true);
    InterpolateCameraPos(playerid, 1160.6168, -1647.9303, 48.0613, 1160.6168, -1647.9303, 48.1613, 1000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, 1159.7582, -1647.4125, 47.4964, 1159.7582, -1647.4125, 47.5964, 1000, CAMERA_MOVE);

    SelectTextDraw(playerid, 0x74c624ff);
}

//------------------------------------------------------------------------------

IsPlayerInTutorial(playerid)
{
    return gIsPlayerInTutorial[playerid];
}
