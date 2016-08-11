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

// Intervalo entre as mensagens aleatórias do servidor em milisegundos
#define ADVERTISE_INTERVAL								300000

// Intervalo entre os nome do servidor aleatórios em milisegundos
#define UPDATE_HOSTNAME_INTERVAL						15000

#define MAX_PLAYER_PASSWORD								32

// Quantidade maxima de corridas que o servidor pode carregar
#define MAX_RACES										64

// Quantidade maxima de checkpoints que a corrida pode ter
#define MAX_RACE_CHECKPOINTS							32

// Quantidade máxima de corredores em corridas
#define MAX_RACE_PLAYERS								10

// Quantos segundos a corrida irá levar para iniciar após o limite minimo de jogadores ser atingido
#define RACE_COUNT_DOWN									30

// Quantos segundos o evento irá levar para iniciar após ser criado
#define EVENT_COUNT_DOWN								60

#define MAX_RACE_NAME									64
#define MINIMUM_PLAYERS_TO_START_RACE					1
#define INVALID_RACE_ID                                -1

//------------------------------------------------------------------------------

// Bibliotecas
#include <streamer>
#include <next-ac>
#include <sscanf2>
#include <a_mysql>
#include <YSI\y_hooks>
#include <YSI\y_timers>
#include <YSI\y_iterate>
#include <YSI\y_commands>
#include <YSI\y_va>
#include <drift>
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
	AddPlayerClass(299, 2234.6855, -1260.9462, 23.9329, 270.0490, 0, 0, 0, 0, 0, 0);
	return 1;
}

//------------------------------------------------------------------------------

// Modulos
/* Definições */
#include "../modules/def/dialog.pwn"
#include "../modules/def/colors.pwn"
#include "../modules/def/messages.pwn"
#include "../modules/def/ranks.pwn"

/* Visual */
#include "../modules/visual/authentication.pwn"
#include "../modules/visual/lobby.pwn"

/* Dados */
#include "../modules/data/player.pwn"

/* Jogador */
#include "../modules/player/commands.pwn"

/* Admin */
#include "../modules/admin/commands.pwn"

/* Core */
#include "../modules/core/timers.pwn"
#include "../modules/core/advertisements.pwn"

/* Gameplay */
#include "../modules/gameplay/bank.pwn"
#include "../modules/gameplay/chat.pwn"
#include "../modules/gameplay/colors.pwn"
#include "../modules/gameplay/tuning.pwn"
#include "../modules/gameplay/racecreator.pwn"
#include "../modules/gameplay/races.pwn"
#include "../modules/gameplay/drift.pwn"
#include "../modules/gameplay/events.pwn"
#include "../modules/gameplay/anticheat.pwn"

//------------------------------------------------------------------------------

main()
{
	printf("\n\n%s %d.%d.%d initialiazed.\n", SCRIPT_VERSION_NAME, SCRIPT_VERSION_MAJOR, SCRIPT_VERSION_MINOR, SCRIPT_VERSION_PATCH);
	print("============================================================\n");
}
