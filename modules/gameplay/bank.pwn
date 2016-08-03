/*******************************************************************************
* NOME DO ARQUIVO :        modules/gameplay/bank.pwn
*
* DESCRIÇÃO :
*       Adiciona conta bancária para os jogadores.
*
* NOTAS :
*       -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

YCMD:transferir(playerid, params[], help)
{
   new targetid, amount;
   if(sscanf(params, "ui", targetid, amount))
       return SendClientMessage(playerid, COLOR_INFO, "* /transferir [playerid] [quantia]");

   else if(!IsPlayerLogged(targetid))
       return SendClientMessage(playerid, COLOR_ERROR, "* O jogador não está conectado.");

   else if(targetid == playerid)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não pode transferir para você mesmo.");

   else if(GetPlayerBankCash(playerid) < amount)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não possui essa quantia de dinheiro no banco.");

   SetPlayerBankCash(playerid, GetPlayerBankCash(playerid) - amount);
   SetPlayerBankCash(targetid, GetPlayerBankCash(targetid) + amount);
   SendClientMessagef(targetid, COLOR_PLAYER_COMMAND, "* %s transferiu $%d para você.", GetPlayerNamef(playerid), amount);
   SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você transferiu $%d para %s.", amount, GetPlayerNamef(targetid));
   return 1;
}

//------------------------------------------------------------------------------

YCMD:depositar(playerid, params[], help)
{
   new amount;
   if(sscanf(params, "i", amount))
       return SendClientMessage(playerid, COLOR_INFO, "* /depositar [quantia]");

   else if(GetPlayerCash(playerid) < amount)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não possui essa quantia de dinheiro na mão.");

   SetPlayerCash(playerid, GetPlayerCash(playerid) - amount);
   SetPlayerBankCash(playerid, GetPlayerBankCash(playerid) + amount);
   SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você depositou $%d.", amount);
   return 1;
}

//------------------------------------------------------------------------------

YCMD:sacar(playerid, params[], help)
{
   new amount;
   if(sscanf(params, "i", amount))
       return SendClientMessage(playerid, COLOR_INFO, "* /sacar [quantia]");

   else if(GetPlayerBankCash(playerid) < amount)
       return SendClientMessage(playerid, COLOR_ERROR, "* Você não possui essa quantia de dinheiro no banco.");

   SetPlayerCash(playerid, GetPlayerCash(playerid) + amount);
   SetPlayerBankCash(playerid, GetPlayerBankCash(playerid) - amount);
   SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você sacou $%d.", amount);
   return 1;
}

//------------------------------------------------------------------------------

YCMD:saldo(playerid, params[], help)
{
   SendClientMessagef(playerid, COLOR_PLAYER_COMMAND, "* Você possui $%d no banco.", GetPlayerBankCash(playerid));
   return 1;
}

//------------------------------------------------------------------------------
