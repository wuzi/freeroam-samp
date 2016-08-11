/*******************************************************************************
* NOME DO ARQUIVO :        modules/core/ads.pwn
*
* DESCRIÇÃO :
*       Envia anúncios pre-definidos a cada x segundos para todos no servidor.
*
* NOTAS :
*       -
*/

static messages[][] = {
    "Mensagem 1",
    "Mensagem 2",
    "Mensagem 3",
    "Mensagem 4",
    "Mensagem 5",
    "Mensagem 6",
    "Mensagem 7",
    "Mensagem 8",
    "Mensagem 9"
};

task SendGlobalAdvertise[ADVERTISE_INTERVAL]()
{
    SendClientMessageToAll(0xffde00ff, messages[random(sizeof(messages))]);
}

//------------------------------------------------------------------------------

static hostnames[][] = {
    "Liberty Freeroam Hostname 1",
    "Liberty Freeroam Hostname 2",
    "Liberty Freeroam Hostname 3",
    "Liberty Freeroam Hostname 4",
    "Liberty Freeroam Hostname 5",
    "Liberty Freeroam Hostname 6",
    "Liberty Freeroam Hostname 7",
    "Liberty Freeroam Hostname 8",
    "Liberty Freeroam Hostname 9"
};

task UpdateHostName[UPDATE_HOSTNAME_INTERVAL]()
{
    new cmd[128];
    format(cmd, sizeof(cmd), "hostname %s", hostnames[random(sizeof(hostnames))]);
    SendRconCommand(cmd);
}
