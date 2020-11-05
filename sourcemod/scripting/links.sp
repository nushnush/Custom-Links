#pragma semicolon 1
#include <sourcemod>
#pragma newdecls required

ArrayList cmds, links;

public Plugin myinfo = {
	name = "[SM] Custom Commands/Links",
	author = "poonit",
	description = "Create custom links for players using MOTD!",
	version = "1.0",
	url = "https://steamcommunity.com/id/kenmaskimmeod/"
};

public void OnPluginStart()
{
    RegAdminCmd("sm_reload_links", Cmd_Reload, ADMFLAG_CONFIG);

    cmds = new ArrayList(ByteCountToCells(64));
    links = new ArrayList(ByteCountToCells(512));

    if(!CreateCommands())
    {
        PrintToServer("[SM] Unable to reload links.cfg, file was not found.");
    }
}

bool CreateCommands()
{
    char sPath[256], sCmd[64], sLink[512];
    BuildPath(Path_SM, sPath, sizeof(sPath), "configs/links.cfg");

    if(!FileExists(sPath))
    {
        return false;
    }
    
    KeyValues kv = new KeyValues("Links");
    kv.ImportFromFile(sPath);
    kv.GotoFirstSubKey();
	
    do
    {
        kv.GetString("command", sCmd, sizeof(sCmd));
        cmds.PushString(sCmd);
        kv.GetString("link", sLink, sizeof(sLink));
        links.PushString(sLink);
        RegConsoleCmd(sCmd, Cmd_Link);
    }
    while (kv.GotoNextKey());

    kv.Rewind();
    delete kv;
    return true;
}

public Action Cmd_Link(int client, int args)
{
    char sCmd[64], sLink[512];
    GetCmdArg(0, sCmd, sizeof(sCmd));
    links.GetString(cmds.FindString(sCmd), sLink, sizeof(sLink));
    ShowLink(client, sLink);
    return Plugin_Handled;
}

public Action Cmd_Reload(int client, int args)
{
    cmds = new ArrayList(ByteCountToCells(64));
    links = new ArrayList(ByteCountToCells(512));

    if(CreateCommands())
    {
        ReplyToCommand(client, "[SM] Successfully reloaded links.cfg");
    }
    else 
    {
        ReplyToCommand(client, "[SM] Unable to reload links.cfg, file was not found.");
    }
    
    return Plugin_Handled;
}

void ShowLink(const int client, const char[] link)
{
    KeyValues kv = new KeyValues("data");
    kv.SetString("title", "Link");
    kv.SetNum("type", MOTDPANEL_TYPE_URL);
    kv.SetString("msg", link);
    ShowVGUIPanel(client, "info", kv, true);
    delete kv;
}