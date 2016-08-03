/*******************************************************************************
* NOME DO ARQUIVO :		main.pwn
*
* DESCRIÇÃO :
*	   Inclui todos os modulos, bibliotecas e configurações do gamemode
*
* NOTAS :
*	   Este arquivo NÃO deve ser usado para manusear informações do gamemode,
*		apenas servir como ponte para os modulos se conectarem.
*
*/

// NECESSÁRIO estar no topo
#include <a_samp>

//------------------------------------------------------------------------------

// Versão do script
#define SCRIPT_VERSION_MAJOR							0
#define SCRIPT_VERSION_MINOR							1
#define SCRIPT_VERSION_PATCH							0
#define SCRIPT_VERSION_NAME								"BD Drift"

// Banco de Dados
#define MySQL_HOST                                      "127.0.0.1"
#define MySQL_USER                                      "root"
#define MySQL_DB                                        "bddrift"
#define MySQL_PASS                                      ""
new gMySQL;

//------------------------------------------------------------------------------

#define MAX_CREATED_VEHICLE_PER_PLAYER					1

//------------------------------------------------------------------------------

// Bibliotecas
#include <sscanf2>
#include <a_mysql>
#include <YSI\y_hooks>
#include <YSI\y_commands>
#include <YSI\y_va>
#include <utils>

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
	print("\n\n============================================================\n");
	print("Initializing...\n");
	SetGameModeText(SCRIPT_VERSION_NAME " " #SCRIPT_VERSION_MAJOR "." #SCRIPT_VERSION_MINOR "." #SCRIPT_VERSION_PATCH);

	// Conexão com o banco de dados MySQL
	mysql_log(LOG_ERROR | LOG_WARNING | LOG_DEBUG); // Usado para debug, comentar quando for para produção
	gMySQL = mysql_connect(MySQL_HOST, MySQL_USER, MySQL_DB, MySQL_PASS);
	if(mysql_errno(gMySQL) != 0)
	{
		print("ERROR: Could not connect to database!");
		return -1; // Parar inicialização se não foir possível conectar ao banco de dados.
	}
	else
		printf("[mysql] connected to database %s at %s successfully!", MySQL_DB, MySQL_HOST);

	// Configurações do Gamemode
	ShowNameTags(1);
	UsePlayerPedAnims();
	DisableInteriorEnterExits();
	SetNameTagDrawDistance(40.0);
	EnableStuntBonusForAll(false);
	return 1;
}

//------------------------------------------------------------------------------

// Modulos
/* Definições */
#include "../modules/def/dialog.pwn"
#include "../modules/def/colors.pwn"
#include "../modules/def/messages.pwn"

/* Dados */
#include "../modules/data/player.pwn"

/* Jogador */
#include "../modules/player/commands.pwn"

//------------------------------------------------------------------------------

main()
{
	printf("\n\n%s %d.%d.%d initialiazed.\n", SCRIPT_VERSION_NAME, SCRIPT_VERSION_MAJOR, SCRIPT_VERSION_MINOR, SCRIPT_VERSION_PATCH);
	print("============================================================\n");
}
