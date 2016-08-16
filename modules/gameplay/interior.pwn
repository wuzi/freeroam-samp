/*******************************************************************************
* NOME DO ARQUIVO :		modules/gameplay/interior.pwn
*
* DESCRIÇÃO :
*	   Adiciona o comando /interiores para teleportar.
*
* NOTAS :
*	   -
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

enum e_interior_data
{
    e_interior_id,
    e_interior_name[64],
    Float:e_interior_x,
    Float:e_interior_y,
    Float:e_interior_z,
    Float:e_interior_a
}
static gInteriorData[146][e_interior_data];

//------------------------------------------------------------------------------

YCMD:interiores(playerid, params[], help)
{
    new output[4096], string[128];
    strcat(output, "ID\tNome\n");
    for(new i = 0; i < sizeof(gInteriorData); i++)
    {
        format(string, sizeof(string), "%i\t%s\n", i + 1, gInteriorData[i][e_interior_name]);
        strcat(output, string);
    }
    ShowPlayerDialog(playerid, DIALOG_INTERIOR_LIST, DIALOG_STYLE_TABLIST_HEADERS, "Interiores", output, "Teleportar", "Voltar");
    return 1;
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch (dialogid)
    {
        case DIALOG_INTERIOR_LIST:
        {
            if(response)
            {
                if(GetPlayerGamemode(playerid) == GAMEMODE_FREEROAM)
                {
                    SetPlayerInterior(playerid, gInteriorData[listitem][e_interior_id]);
                    SetPlayerPos(playerid, gInteriorData[listitem][e_interior_x], gInteriorData[listitem][e_interior_y], gInteriorData[listitem][e_interior_z]);
                    SetPlayerFacingAngle(playerid, gInteriorData[listitem][e_interior_a]);
                    SendClientMessagef(playerid, COLOR_SUCCESS, "* Você teleportou para %s.", gInteriorData[listitem][e_interior_name]);
                    PlaySelectSound(playerid);
                }
                else
                {
                    PlayErrorSound(playerid);
                    SendClientMessage(playerid, COLOR_ERROR, "* Você não pode usar este comando neste modo de jogo.");
                }
            }
            else
            {
                PlayCancelSound(playerid);
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    LoadInteriorsFromFile("interiors.txt");
    return 1;
}

//------------------------------------------------------------------------------

stock LoadInteriorsFromFile(const filename[])
{
	new File:file_ptr;
	new line[256];
	new var_from_line[64];
    new index;
    new interiors_loaded;

	file_ptr = fopen(filename,filemode:io_read);
	if(!file_ptr) return 0;

	interiors_loaded = 0;

	while(fread(file_ptr,line,256) > 0)
	{
	    index = 0;

  		index = token_by_delim(line,var_from_line,' ',index);
  		if(index == (-1)) continue;
  		gInteriorData[interiors_loaded][e_interior_id] = strval(var_from_line);
   		if(gInteriorData[interiors_loaded][e_interior_id] < 0) continue;

  		index = token_by_delim(line,var_from_line,' ',index+1);
  		if(index == (-1)) continue;
  		gInteriorData[interiors_loaded][e_interior_x] = floatstr(var_from_line);

  		index = token_by_delim(line,var_from_line,' ',index+1);
  		if(index == (-1)) continue;
  		gInteriorData[interiors_loaded][e_interior_y] = floatstr(var_from_line);

  		index = token_by_delim(line,var_from_line,' ',index+1);
  		if(index == (-1)) continue;
  		gInteriorData[interiors_loaded][e_interior_z] = floatstr(var_from_line);

  		index = token_by_delim(line,var_from_line,' ',index+1);
  		if(index == (-1)) continue;
  		gInteriorData[interiors_loaded][e_interior_a] = floatstr(var_from_line);

  		index = token_by_delim(line,var_from_line,';',index+1);
  		strcat(gInteriorData[interiors_loaded][e_interior_name], var_from_line);

		interiors_loaded++;
	}

	fclose(file_ptr);
	printf("Loaded %d interiors from: %s",interiors_loaded,filename);
	return interiors_loaded;
}

//------------------------------------------------------------------------------

stock token_by_delim(const string[], return_str[], delim, start_index)
{
	new x=0;
	while(string[start_index] != EOS && string[start_index] != delim) {
	    return_str[x] = string[start_index];
	    x++;
	    start_index++;
	}
	return_str[x] = EOS;
	if(string[start_index] == EOS) start_index = (-1);
	return start_index;
}

//------------------------------------------------------------------------------
