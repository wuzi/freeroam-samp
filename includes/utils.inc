/*******************************************************************************
* NOME DO ARQUIVO :        utils.inc
*
* DESCRIÇÃO :
*       Macros e funções uteis para GTA:SA-MP Pawn.
*
* NOTES :
*       -
*
*/

//------------------------------------------------------------------------------

/*
    Macros para som
*/
#define PlayConfirmSound(%0)    PlayerPlaySound(%0,1058,0.0,0.0,0.0)
#define PlaySelectSound(%0)     PlayerPlaySound(%0,1083,0.0,0.0,0.0)
#define PlayCancelSound(%0)     PlayerPlaySound(%0,1084,0.0,0.0,0.0)
#define PlayErrorSound(%0)      PlayerPlaySound(%0,1085,0.0,0.0,0.0)

//------------------------------------------------------------------------------

/*
        ClearPlayerScreen
    DESCRIÇÃO:
        Limpar o chat do jogador.
    args:
        playerid - ID do jogador.
        lines - Quantidade de linhas. (opcional)
*/
stock ClearPlayerScreen(playerid, lines = 100)
{
    for(new i = 0; i < lines; i++)
        SendClientMessage(playerid, -1, " ");
}

//------------------------------------------------------------------------------

// Convert UNIX time to human readable time
stock convertTimestamp( timestamp, _form=0 )
{
    timestamp -= 10800;
    new year=1970, day=0, month=0, hour=0, mins=0, sec=0;

    new days_of_month[12] = { 31,28,31,30,31,30,31,31,30,31,30,31 };
    new names_of_month[12][10] = {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"};
    new returnstring[32];

    while(timestamp>31622400){
        timestamp -= 31536000;
        if ( ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0) ) timestamp -= 86400;
        year++;
    }

    if ( ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0) )
        days_of_month[1] = 29;
    else
        days_of_month[1] = 28;


    while(timestamp>86400){
        timestamp -= 86400, day++;
        if(day==days_of_month[month]) day=0, month++;
    }

    while(timestamp>60){
        timestamp -= 60, mins++;
        if( mins == 60) mins=0, hour++;
    }

    sec=timestamp;

    switch( _form ){
        case 1: format(returnstring, 31, "%02d/%02d/%d %02d:%02d:%02d", day+1, month+1, year, hour, mins, sec);
        case 2: format(returnstring, 31, "%s %02d, %d, %02d:%02d:%02d", names_of_month[month],day+1,year, hour, mins, sec);
        case 3: format(returnstring, 31, "%d %c%c%c %d, %02d:%02d", day+1,names_of_month[month][0],names_of_month[month][1],names_of_month[month][2], year,hour,mins);
        case 4: format(returnstring, 31, "%02d.%02d.%d-%02d:%02d:%02d", day+1, month+1, year, hour, mins, sec);
        default: format(returnstring, 31, "%02d:%02d:%02d %02d/%02d/%d", hour, mins, sec, day+1, month+1, year);
    }

    return returnstring;
}
