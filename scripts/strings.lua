---@class SAString
local SA = {
    HUD = {
        ALARM_TITLE = "INC FIREWALL LEVEL",
        ALLIANCE_ACTIVITY = "ALLIANCE ACTIVITY",
        CONNECT_SHOAPCAT = "CONNECT\nSHOPCAT>",
        DISCONNECT_SHOPCAT = "DISCONNECT\nSHOPCAT<"
    },
    GUARDS = {
        ALLY_ELITE_ENFORCER = "ALLY ENFORCER",
    },
    LEVEL = {
        HUD_WARN_EXIT_MISSION_FACTORY = "Are you sure you want to leave? You haven't destroy the control center yet."
    },
    PROGRAMS = {
        LOCK = {
            NAME = "LOCK",
            DESC = "Lock 1 firewall for 2 PWR.",
            HUD_DESC = "LOCK 1 FIREWALL",
            SHORT_DESC = "USE LOCK",
            TIP_DESC = "LOCK <c:FF8411>1 FIREWALL</c>. COST: <c:77FF77>{1} PWR</c>"
        },
        RATCHET = {
            NAME = "RATCHET",
            DESC = "Lock 1 firewall and Increase 1 upper limit for 2 PWR.",
            HUD_DESC = "LOCK 1 FIREWALL AND INCREASE 1 LIMIT",
            SHORT_DESC = "USE RATCHET",
            TIP_DESC = "LOCK <c:FF8411>1 FIREWALL</c> AND INCREASE <c:FF8411>1 LIMIT</c>. COST: <c:77FF77>{1} PWR</c>"
        },
    },
    DAEMON = {
        LOCKPICK =
        {
            NAME = "LOCKPICK",
            DESC = "Breaks 1 firewall for 2 PWR.",
            HUD_DESC = "BREAK 1 FIREWALL",
            SHORT_DESC = "BREAK FIREWALL",
            ACTIVE_DESC = "BREAK 1 FIREWALL",
            TIP_DESC = "BREAK <c:FF8411>1 FIREWALL</c>. COST: <c:77FF77>{1} PWR</c>",
        },
        MARCH =
        {
            NAME = "MARCH",
            DESC = "Control all robots to act",
            HUD_DESC = "CONTROL ROBOTS",
            SHORT_DESC = "CONTROL ROBOTS",
            ACTIVE_DESC = "ROBOTS WILL TAKE ACTION",
            TIP_DESC = "Control all robots to act",
        },
    },
    UI = {
        SHOPCAT_NAME = "SHOPCAT",
        INC_FIREWALL_TOOLTIP =
        "INC uses firewall to block incognita's intrusion. Once the firewall is breached, Incognita will install daemons. Each time it is breached, the installed daemon becomes more and more dangerous",
        RALF_TITLE = "RALF",
    },
    MISSIONS = {
        FACTORY = {
            "Situation's worse than projected. Incognita's Hunter-Killer protocols are live. Tens of thousands of people killed by Thanatos Drone. That factory's pumping out this new drones every minute. Our agents can't engage directly—those things move faster than human limits.", --Central
            "Invisible Inc excels at data purges, but flesh can't stop titanium blades. Proposal: Accept our Pyro suppression squad. Payment?... Negotiable post-mission.", --Ralf
            "Heyyyyy boys, guess who just hacked your secure line? (static-laced chuckle) Incognita says: 'Flesh rusts, code endures'—oh and it just... (explosion) SHIT! They're on me!", --Monst3r
            " No time to debate. Monst3r's signal just died near West Sector vents. Your troops clear the path, my agents handle the purge. Remember: If those kill-codes escape that factory, the whole city will become a slaughterhouse.", --Central
            "Approved. Pyro suppression squad has arrived factory. Hacking the facility elevator.", --Ralf
            "Operator, ready to act. In 15 minutes, I either see that factory core burns, or the entire city burns in drone’s plasma fire.", --Central
        },
    },
}
return SA
