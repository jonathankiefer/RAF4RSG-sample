'*********************************************************************
'** (c) 2016-2017 Roku, Inc.  All content herein is protected by U.S.
'** copyright and other applicable intellectual property laws and may
'** not be copied without the express permission of Roku, Inc., which
'** reserves all rights.  Reuse of any of this content for any purpose
'** without the permission of Roku, Inc. is strictly prohibited.
'*********************************************************************

sub init()
    'we use a simple LabelList for a menu
    m.list = m.top.FindNode("list")
    m.list.observeField("itemSelected", "onItemSelected")
    m.list.SetFocus(true)

    'descriptor for the menu items
    itemList = [
        {
            title: "Single pre-roll ad"
            url: "https://securepubads.g.doubleclick.net/gampad/ads?env=vp&gdfp_req=1&output=xml_vast3&unviewed_position_start=1&sz=640x480&url=https%3A%2F%2Fwww.yidio.com&iu=/1018653/video_unit_roku&sdkv=h.3.441.0&vad_type=linear&rdid=ROKU_ADS_TRACKING_ID&is_lat=ROKU_ADS_LIMIT_TRACKING&idtype=rida&correlator=ROKU_ADS_TIMESTAMP&scor=ROKU_ADS_TIMESTAMP&cust_params=genre%3DROKU_ADS_CONTENT_GENRE%26ua%3DROKU_ADS_USER_AGENT"
        }
        {
            title: "Multiple mid-roll ads"
            url: "https://securepubads.g.doubleclick.net/gampad/ads?env=vp&gdfp_req=1&output=xml_vast3&unviewed_position_start=1&sz=640x480&url=https%3A%2F%2Fwww.yidio.com&iu=/1018653/video_unit_roku&sdkv=h.3.441.0&vad_type=linear&rdid=ROKU_ADS_TRACKING_ID&is_lat=ROKU_ADS_LIMIT_TRACKING&idtype=rida&correlator=ROKU_ADS_TIMESTAMP&scor=ROKU_ADS_TIMESTAMP&cust_params=genre%3DROKU_ADS_CONTENT_GENRE%26ua%3DROKU_ADS_USER_AGENT"
            ad_breaks: [700, 1300, 1900]
        }
    ]

    ' compile into a ContentNode structure
    listNode = CreateObject("roSGNode", "ContentNode")
    for each item in itemList:
        nod = CreateObject("roSGNode", "ContentNode")
        nod.setFields(item)
        listNode.appendChild(nod)
    next
    m.list.content = listNode

end sub

sub onItemSelected()
    m.list.SetFocus(false) ' un-set focus to avoid creating multiple players on user tapping twice
    menuItem = m.list.content.getChild(m.list.itemSelected)

    videoContent = {

        streamFormat: "smooth"
        title: "The Big Boss"
        url:  "http://flixflingmedia.origin.mediaservices.windows.net/91e9d880-f022-4cca-96f0-602de151e471/TheBigBoss_En_Subs_1080p.ism/manifest"

        'used for raf.setContentGenre(). For ads provided by the Roku ad service, see docs on 'Roku Genre Tags'
        categories: ["Action"]

        'Roku mandates that all channels enable Nielsen DAR
        nielsen_app_id: "P2871BBFF-1A28-44AA-AF68-C7DE4B148C32" 'required, put "P2871BBFF-1A28-44AA-AF68-C7DE4B148C32", Roku's default appId if not having ID from Nielsen
        nielsen_genre: "DO" 'required, put "GV" if dynamic genre or special circumstances (e.g. games)
        nielsen_program_id: "The Big Boss" 'movie title or series name
        length: 5940

    }
    
    ' compile into a VideoContent node
    content = CreateObject("roSGNode", "VideoContent")
    content.setFields(videoContent)
    content.ad_url = menuItem.url
    content.ad_breaks = menuItem.ad_breaks

    if m.Player = invalid:
        m.Player = m.top.CreateChild("Player")
        m.Player.observeField("state", "PlayerStateChanged")
    end if

    'start the player
    m.Player.content = content
    m.Player.visible = true
    m.Player.control = "play"
end sub

sub PlayerStateChanged()
    print "EntryScene: PlayerStateChanged(), state = "; m.Player.state
    if m.Player.state = "done" or m.Player.state = "stop"
        m.Player.visible = false
        m.list.setFocus(true) 'NB. the player took the focus away, so get it back
    end if
end sub
