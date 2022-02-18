#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Nick Moderation", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

ConVar Limit = null, Announce = null, Limit_Type = null, Limit_Type_Ban = null;

int Check[65] = { 0, ... };

public void OnPluginStart()
{
	HookEvent("player_changename", Control_ChangeNick);
	Limit = CreateConVar("sm_changenick_limit", "3", "Bir oyuncu en fazla kaç nick değiştirebilir [ 0 = Kapatır ]", 0, true, 0.0, false);
	Limit_Type = CreateConVar("sm_changenick_limit_type", "0", "Bir oyuncu çok fazla nick değiştirdiğinde ne yapılsın [ 0 = Kick | 1 = Ban ]", 0, true, 0.0, true, 1.0);
	Limit_Type_Ban = CreateConVar("sm_changenick_limit_type_ban", "15", "Bir oyuncu çok fazla nick değiştirdiğinde ne kadar dakika banlansın [ Cezanın ban olması gerek ]", 0, true, 1.0, false);
	Announce = CreateConVar("sm_changenick_announce", "1", "Bir oyuncu nick değiştirdiğinde duyurulsun mu? [ 1 = Evet | 0 = Hayır ]", 0, true, 0.0, true, 1.0);
	AutoExecConfig(true, "Nick-Moderation", "ByDexter");
}

public void OnClientPostAdminCheck(int client)
{
	Check[client] = 0;
}

public Action Control_ChangeNick(Event event, const char[] name, bool db)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(client))
	{
		if (Limit.IntValue > 0)
		{
			Check[client]++;
			if (Check[client] > Limit.IntValue)
			{
				if (!Limit_Type.BoolValue)
				{
					KickClient(client, "Çok Fazla İsim Değiştirdiğiniz");
				}
				else
				{
					BanClient(client, Limit_Type_Ban.IntValue, BANFLAG_AUTHID, "Çok Fazla İsim Değiştirdiğiniz");
				}
			}
			PrintToChat(client, "[SM] \x07%d İsim değiştirme hakkınız kaldı.", Limit.IntValue - Check[client]);
		}
		if (Announce.BoolValue)
		{
			char oldname[128], newname[128];
			event.GetString("oldname", oldname, 128);
			event.GetString("newname", newname, 128);
			PrintToChatAll("[SM] \x10%s \x0E(#%d) \x01ismini \x10%s \x0E(#%d) \x06olarak değiştirdi.", oldname, GetClientUserId(client), newname, GetClientUserId(client));
		}
	}
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
}
