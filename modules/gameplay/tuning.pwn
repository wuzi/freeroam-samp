/*******************************************************************************
* NOME DO ARQUIVO :        modules/gameplay/tuning.pwn
*
* DESCRIÇÃO :
*       Permite jogadores tunar seus veículos em qualquer lugar
*
* NOTAS :
*       -
*/

//------------------------------------------------------------------------------

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

static mainMenu[]       = "PaintJobs\nCores\nEscapamento\nParachoque Dianteiro\nParachoque Traseiro\nTeto\nAerofoleo\nSaias laterais\nBarra de proteção frontal\nRodas\nNitro\nCapô\nRespirador\nFarol\nSom Stereo\nHidraulica\nReparar";
static paintjobMenu[]   = "PaintJob #1\nPaintJob #2\nPaintJob #3";
static colorMenu[]      = "Digite a cor que deseja pintar o veículo:\nSepare as cores por um espaço, exemplo: 1 126.";
static exhaustMenu[]    = "Wheel Arc. Alien exhaust\nWheel Arc. X-Flow exhaust\nLow Co. Chromer exhaust\nLow Co. Slamin exhaust\nTransfender Large exhaust\nTransfender Medium exhaust\nTransfender Small exhaust\nTransfender Twin exhaust\nTransfender Upswept exhaust";
static fbumpMenu[]      = "Wheel Arc. Alien Bumper\nWheel Arc. X-Flow Bumper\nLow co. Chromer Bumper\nLow co. Slamin Bumper";
static rbumpMenu[]      = "Wheel Arc. Alien Bumper\nWheel Arc. X-Flow Bumper\nLow Co. Chromer Bumper\nLow Co. Slamin Bumper";
static roofMenu[]       = "Wheel Arc. Alien\nWheel Arc. X-Flow\nLow Co. Hardtop Roof\nLow Co. Softtop Roof\nTransfender Roof Scoop";
static spoilerMenu[]    = "Wheel Arc. Alien Spoiler\nWheel Arc. X-Flow Spoiler\nTransfender Win Spoiler\nTransfender Fury Spoiler\nTransfender Alpha Spoiler\nTransfender Pro Spoiler\nTransfender Champ Spoiler\nTransfender Race Spoiler\nTransfender Drag Spoiler";
static skirtMenu[]      = "Wheel Arc. Alien Side Skirt\nWheel Arc. X-Flow Side Skirt\nLocos Chrome Strip\nLocos Chrome Flames\nLocos Chrome Arches \nLocos Chrome Trim\nLocos Wheelcovers\nTransfender Side Skirt";
static bullbarMenu[]    = "Locos Chrome Grill\nLocos Chrome Bars\nLocos Chrome Lights \nLocos Chrome Bullbar";
static wheelMenu[]      = "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\nTrance\nShadow\nRimshine\nClassic\nCutter\nSwitch\nDollar";
static nitroMenu[]      = "2x Nitrous\n5x Nitrous\n10x Nitrous";
static hoodMenu[]       = "Fury\nChamp\nRace\nWorx";
static ventMenu[]       = "Oval\nSquare";
static lightMenu[]      = "Round\nSquare";

//------------------------------------------------------------------------------

YCMD:tunar(playerid, params[], help)
{
    if(!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, COLOR_ERROR, "* Você precisa estar em um veículo para tunar.");

    else if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendClientMessage(playerid, COLOR_ERROR, "* Você precisa ser o motorista para tunar o veículo.");

    ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
    PlaySelectSound(playerid);
    return 1;
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_TUNING:
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
                        if(!IsValidPaintJobVehicle(GetPlayerVehicleID(playerid)))
                        {
                            PlayErrorSound(playerid);
                            ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                            SendClientMessage(playerid, COLOR_ERROR, "* Não é possível aplicar paintjob neste veículo.");
                        }
                        else
                        {
                            PlayConfirmSound(playerid);
                            ShowPlayerDialog(playerid, DIALOG_TUNING_PAINTJOB, DIALOG_STYLE_LIST, "Tunar", paintjobMenu, "Confirmar", "Voltar");
                        }
                    }
                    case 1:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_COLOR, DIALOG_STYLE_INPUT, "Tunar", colorMenu, "Confirmar", "Voltar");
                    }
                    case 2:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_EXHAUST, DIALOG_STYLE_LIST, "Tunar", exhaustMenu, "Confirmar", "Voltar");
                    }
                    case 3:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_FBUMP, DIALOG_STYLE_LIST, "Tunar", fbumpMenu, "Confirmar", "Voltar");
                    }
                    case 4:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_RBUMP, DIALOG_STYLE_LIST, "Tunar", rbumpMenu, "Confirmar", "Voltar");
                    }
                    case 5:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_ROOF, DIALOG_STYLE_LIST, "Tunar", roofMenu, "Confirmar", "Voltar");
                    }
                    case 6:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_SPOILER, DIALOG_STYLE_LIST, "Tunar", spoilerMenu, "Confirmar", "Voltar");
                    }
                    case 7:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_SKIRT, DIALOG_STYLE_LIST, "Tunar", skirtMenu, "Confirmar", "Voltar");
                    }
                    case 8:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_BULLBAR, DIALOG_STYLE_LIST, "Tunar", bullbarMenu, "Confirmar", "Voltar");
                    }
                    case 9:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_WHEEL, DIALOG_STYLE_LIST, "Tunar", wheelMenu, "Confirmar", "Voltar");
                    }
                    case 10:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_NITRO, DIALOG_STYLE_LIST, "Tunar", nitroMenu, "Confirmar", "Voltar");
                    }
                    case 11:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_HOOD, DIALOG_STYLE_LIST, "Tunar", hoodMenu, "Confirmar", "Voltar");
                    }
                    case 12:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_VENT, DIALOG_STYLE_LIST, "Tunar", ventMenu, "Confirmar", "Voltar");
                    }
                    case 13:
                    {
                        PlayConfirmSound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING_LIGHT, DIALOG_STYLE_LIST, "Tunar", lightMenu, "Confirmar", "Voltar");
                    }
                    case 14:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1086);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 15:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1087);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 16:
                    {
                        RepairVehicle(GetPlayerVehicleID(playerid));
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
        case DIALOG_TUNING_PAINTJOB:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                PlayBuySound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                ChangeVehiclePaintjob(GetPlayerVehicleID(playerid), listitem);
            }
        }
        case DIALOG_TUNING_COLOR:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                new color1, color2;
             	if(sscanf(inputtext, "ii", color1, color2))
             	{
                    PlayErrorSound(playerid);
                    SendClientMessage(playerid, COLOR_ERROR, "* Formato inválido.");
                    ShowPlayerDialog(playerid, DIALOG_TUNING_COLOR, DIALOG_STYLE_INPUT, "Tunar", colorMenu, "Confirmar", "Voltar");
                }
                else
                {
                    PlayBuySound(playerid);
                    ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    ChangeVehicleColor(GetPlayerVehicleID(playerid), color1, color2);
                }
            }
        }
        case DIALOG_TUNING_EXHAUST:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 562:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1034);
                            case 565:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1046);
                            case 559:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1065);
                            case 561:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1064);
                            case 560:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1028);
                            case 558:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1089);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_EXHAUST, DIALOG_STYLE_LIST, "Tunar", exhaustMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 1:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 562:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1037);
                            case 565:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1045);
                            case 559:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1066);
                            case 561:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1059);
                            case 560:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1029);
                            case 558:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1092);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_EXHAUST, DIALOG_STYLE_LIST, "Tunar", exhaustMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 2:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 575:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1044);
                            case 534:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1126);
                            case 567:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1129);
                            case 536:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1104);
                            case 535:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1113);
                            case 576:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1136);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_EXHAUST, DIALOG_STYLE_LIST, "Tunar", exhaustMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 3:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 575:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1043);
                            case 534:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1127);
                            case 567:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1132);
                            case 536:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1105);
                            case 535:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1114);
                            case 576:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1135);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_EXHAUST, DIALOG_STYLE_LIST, "Tunar", exhaustMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 4:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 401, 518, 527, 542, 589, 400, 517, 603, 426, 547, 405, 580, 550, 549, 477:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1020);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_EXHAUST, DIALOG_STYLE_LIST, "Tunar", exhaustMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 5:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 527, 542, 400, 426, 436, 547, 405, 477:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1021);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_EXHAUST, DIALOG_STYLE_LIST, "Tunar", exhaustMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 6:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 436:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1022);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_EXHAUST, DIALOG_STYLE_LIST, "Tunar", exhaustMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 7:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 518, 415, 542, 546, 400, 517, 603, 426, 436, 547, 405, 550, 549, 447:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1019);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_EXHAUST, DIALOG_STYLE_LIST, "Tunar", exhaustMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 8:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 401, 518, 415, 542, 546, 400, 517, 603, 426, 547, 405, 550, 549, 477:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1018);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_EXHAUST, DIALOG_STYLE_LIST, "Tunar", exhaustMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
        case DIALOG_TUNING_FBUMP:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 562:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1171);
                            case 565:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1153);
                            case 559:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1160);
                            case 561:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1155);
                            case 560:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1169);
                            case 558:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1166);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_FBUMP, DIALOG_STYLE_LIST, "Tunar", fbumpMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 1:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 562:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1172);
                            case 565:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1152);
                            case 559:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1173);
                            case 561:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1157);
                            case 560:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1170);
                            case 558:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1165);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_FBUMP, DIALOG_STYLE_LIST, "Tunar", fbumpMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 2:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 575:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1174);
                            case 534:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1179);
                            case 567:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1189);
                            case 536:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1182);
                            case 535:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1115);
                            case 576:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1191);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_FBUMP, DIALOG_STYLE_LIST, "Tunar", fbumpMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 3:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 575:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1175);
                            case 534:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1185);
                            case 567:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1188);
                            case 536:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1181);
                            case 535:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1116);
                            case 576:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1190);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_FBUMP, DIALOG_STYLE_LIST, "Tunar", fbumpMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
        case DIALOG_TUNING_RBUMP:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 562:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1149);
                            case 565:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1150);
                            case 559:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1159);
                            case 561:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1154);
                            case 560:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1141);
                            case 558:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1168);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_RBUMP, DIALOG_STYLE_LIST, "Tunar", rbumpMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 1:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 562:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1148);
                            case 565:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1151);
                            case 559:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1161);
                            case 561:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1156);
                            case 560:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1140);
                            case 558:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1167);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_RBUMP, DIALOG_STYLE_LIST, "Tunar", rbumpMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 2:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 575:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1176);
                            case 534:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1180);
                            case 567:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1187);
                            case 536:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1184);
                            case 535:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1109);
                            case 576:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1192);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_RBUMP, DIALOG_STYLE_LIST, "Tunar", rbumpMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 3:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 575:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1177);
                            case 534:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1178);
                            case 567:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1186);
                            case 536:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1183);
                            case 535:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1110);
                            case 576:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1193);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_RBUMP, DIALOG_STYLE_LIST, "Tunar", rbumpMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
        case DIALOG_TUNING_ROOF:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 562:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1038);
                            case 565:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1054);
                            case 559:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1067);
                            case 561:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1055);
                            case 560:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1032);
                            case 558:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1088);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_ROOF, DIALOG_STYLE_LIST, "Tunar", roofMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 1:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 562:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1035);
                            case 565:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1053);
                            case 559:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1068);
                            case 561:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1061);
                            case 560:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1033);
                            case 558:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1091);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_ROOF, DIALOG_STYLE_LIST, "Tunar", roofMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 2:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 567:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1130);
                            case 536:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1128);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_ROOF, DIALOG_STYLE_LIST, "Tunar", roofMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 3:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 567:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1131);
                            case 536:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1103);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_ROOF, DIALOG_STYLE_LIST, "Tunar", roofMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 4:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 401, 518, 589, 492, 546, 603, 426, 436, 580, 550, 477:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1006);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_ROOF, DIALOG_STYLE_LIST, "Tunar", roofMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
        case DIALOG_TUNING_SPOILER:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 562:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1147);
                            case 565:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1049);
                            case 559:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1162);
                            case 561:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1158);
                            case 560:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1138);
                            case 558:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1164);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SPOILER, DIALOG_STYLE_LIST, "Tunar", spoilerMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 1:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 562:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1146);
                            case 565:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1150);
                            case 559:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1158);
                            case 561:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1160);
                            case 560:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1139);
                            case 558:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1163);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SPOILER, DIALOG_STYLE_LIST, "Tunar", spoilerMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 2:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 401, 518, 527, 415, 546, 603, 426, 436, 405, 477, 580, 550, 549:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1001);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SPOILER, DIALOG_STYLE_LIST, "Tunar", spoilerMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 3:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 518, 415, 546, 517, 603, 405, 477, 580, 550, 549:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1023);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SPOILER, DIALOG_STYLE_LIST, "Tunar", spoilerMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 4:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 518, 415, 401, 517, 426, 436, 477, 547, 550, 549:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1003);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SPOILER, DIALOG_STYLE_LIST, "Tunar", spoilerMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 5:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 589, 492, 547, 405:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1000);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SPOILER, DIALOG_STYLE_LIST, "Tunar", spoilerMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 6:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 527, 542, 405:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1014);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SPOILER, DIALOG_STYLE_LIST, "Tunar", spoilerMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 7:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 527, 542:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1014);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SPOILER, DIALOG_STYLE_LIST, "Tunar", spoilerMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 8:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 546, 517:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1002);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SPOILER, DIALOG_STYLE_LIST, "Tunar", spoilerMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
        case DIALOG_TUNING_SKIRT:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 562:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1036);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1040);
                            }
                            case 565:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1047);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1051);
                            }
                            case 559:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1069);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1071);
                            }
                            case 561:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1056);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1062);
                            }
                            case 560:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1026);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1027);
                            }
                            case 558:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1090);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1094);
                            }
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SKIRT, DIALOG_STYLE_LIST, "Tunar", skirtMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 1:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 562:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1039);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1041);
                            }
                            case 565:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1048);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1052);
                            }
                            case 559:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1070);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1072);
                            }
                            case 561:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1057);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1063);
                            }
                            case 560:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1031);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1030);
                            }
                            case 558:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1093);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1095);
                            }
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SKIRT, DIALOG_STYLE_LIST, "Tunar", skirtMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 2:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 575:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1042);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1099);
                            }
                            case 567:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1102);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1133);
                            }
                            case 576:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1134);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1137);
                            }
                            case 536:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1108);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1107);
                            }
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SKIRT, DIALOG_STYLE_LIST, "Tunar", skirtMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 3:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 534:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1122);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1101);
                            }
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SKIRT, DIALOG_STYLE_LIST, "Tunar", skirtMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 4:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 534:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1106);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1124);
                            }
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SKIRT, DIALOG_STYLE_LIST, "Tunar", skirtMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 5:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 535:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1118);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1120);
                            }
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SKIRT, DIALOG_STYLE_LIST, "Tunar", skirtMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 6:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 535:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1119);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1121);
                            }
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SKIRT, DIALOG_STYLE_LIST, "Tunar", skirtMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 7:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 404, 518, 527, 415, 589, 546, 517, 603, 436, 439, 580, 549, 477:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1007);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1017);
                            }
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_SKIRT, DIALOG_STYLE_LIST, "Tunar", skirtMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
        case DIALOG_TUNING_BULLBAR:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 534:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1100);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_BULLBAR, DIALOG_STYLE_LIST, "Tunar", bullbarMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 1:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 534:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1123);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_BULLBAR, DIALOG_STYLE_LIST, "Tunar", bullbarMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 2:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 534:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1125);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_BULLBAR, DIALOG_STYLE_LIST, "Tunar", bullbarMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 3:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 535:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1117);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_BULLBAR, DIALOG_STYLE_LIST, "Tunar", bullbarMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
        case DIALOG_TUNING_WHEEL:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1025);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 1:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1074);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 2:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1076);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 3:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1078);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 4:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1081);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 5:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1082);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 6:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1085);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 7:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1096);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 8:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1097);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 9:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1098);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 10:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1084);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 11:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1073);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 12:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1075);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 13:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1077);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 14:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1079);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 15:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1080);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 16:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1083);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
        case DIALOG_TUNING_NITRO:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1008);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 1:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1009);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 2:
                    {
                        AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
        case DIALOG_TUNING_HOOD:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 401, 518, 589, 592, 426, 550:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1005);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_HOOD, DIALOG_STYLE_LIST, "Tunar", hoodMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 1:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 401, 492, 546, 426, 550:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1004);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_HOOD, DIALOG_STYLE_LIST, "Tunar", hoodMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 2:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 549:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1011);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_HOOD, DIALOG_STYLE_LIST, "Tunar", hoodMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 3:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 549:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1012);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_HOOD, DIALOG_STYLE_LIST, "Tunar", hoodMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
        case DIALOG_TUNING_VENT:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 401, 518, 546, 517, 603, 547, 439, 550, 549:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1142);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1143);
                            }
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_VENT, DIALOG_STYLE_LIST, "Tunar", ventMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 1:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 401, 518, 589, 546, 517, 603, 439, 550, 549:
                            {
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1144);
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1145);
                            }
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_VENT, DIALOG_STYLE_LIST, "Tunar", ventMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
        case DIALOG_TUNING_LIGHT:
        {
            if(!response)
            {
                PlayCancelSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
            }
            else
            {
                switch (listitem)
                {
                    case 0:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 401, 518, 589, 400, 436, 439:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1013);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_LIGHT, DIALOG_STYLE_LIST, "Tunar", lightMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                    case 1:
                    {
                        switch (GetVehicleModel(GetPlayerVehicleID(playerid)))
                        {
                            case 589, 603, 400:
                                AddVehicleComponent(GetPlayerVehicleID(playerid), 1024);
                            default:
                            {
                                PlayErrorSound(playerid);
                                ShowPlayerDialog(playerid, DIALOG_TUNING_LIGHT, DIALOG_STYLE_LIST, "Tunar", lightMenu, "Confirmar", "Voltar");
                                SendClientMessage(playerid, COLOR_ERROR, "* Não é possível adicionar este componente neste veículo.");
                                return 1;
                            }
                        }
                        PlayBuySound(playerid);
                        ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Tunar", mainMenu, "Confirmar", "Sair");
                    }
                }
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

IsValidPaintJobVehicle(vehicleid)
{
    new valid_id[] = {
        562, 565, 559, 561, 560, 575, 534, 567, 536, 535, 576, 558
    };

    for(new i = 0; i < sizeof(valid_id); i++)
    {
        if(GetVehicleModel(vehicleid) == valid_id[i])
            return 1;
    }
    return 0;
}
