/*******************************************************************************
* NOME DO ARQUIVO :        modules/gameplay/anticheat.pwn
*
* DESCRIÇÃO :
*       Responsável por dar as punições aos jogadores suspeitos de cheating
*
* NOTAS :
*       -
*/

//------------------------------------------------------------------------------

forward OnCheatDetected(playerid, ip_address[], type, code);
public OnCheatDetected(playerid, ip_address[], type, code)
{
    return 1;
}
