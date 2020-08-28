// Martian Gothic: Unification Auto Splitter
// By Kapdap 2020/08/27
// https://github.com/kapdap/mgu-autosplitter

state("martian gothic") {}

startup
{
    vars.splits = new ExpandoObject();
	vars.splits.startgame = false;
    vars.splits.endgame = false;

    settings.Add("events", true, "Events");
    settings.Add("endGame", true, "End Game", "events");

    // Application information
    settings.Add("infogroup", false, "Info");
    settings.Add("infogroup1", false, "Martian Gothic: Unification Auto Splitter by Kapdap", "infogroup");
    settings.Add("infogroup2", false, "Website: https://github.com/kapdap/mgu-autosplitter", "infogroup");
    settings.Add("infogroup3", false, "Last Update: 2020-08-27T22:45:00+1200", "infogroup");
}

init
{
    current.room = 0;
    current.movie = 0;
    current.screen = 0;
    current.switches = 0;
}

start
{
    return (current.screen == 2 && current.movie == 0 || current.movie == 1);
}

update
{
    current.room = memory.ReadValue<byte>(new IntPtr(0x005BB519));
    current.movie = memory.ReadValue<byte>(new IntPtr(0x005BD008));
    current.screen = memory.ReadValue<byte>(new IntPtr(0x00752850));
    current.switches = memory.ReadValue<byte>(new IntPtr(0x005C4708));

    if (timer.CurrentPhase == TimerPhase.NotRunning)
    {
		vars.splits.startgame = false;
        vars.splits.endgame = false;
    }
}

split
{
	if (!vars.splits.startgame)
		vars.splits.startgame = current.switches == 1;

	if (vars.splits.startgame)
	{
		if (current.switches == 0 && current.room == 28 && !vars.splits.endgame)
		{
			vars.splits.endgame = true;
			return settings["endGame"];
		}
	}
}