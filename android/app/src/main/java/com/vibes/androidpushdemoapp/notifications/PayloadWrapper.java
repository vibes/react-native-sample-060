package com.vibes.androidpushdemoapp.notifications;

import com.vibes.vibes.PushPayloadParser;

public class PayloadWrapper {
    private final PushPayloadParser payload;


    public PayloadWrapper(PushPayloadParser payload) {
        this.payload = payload;
    }

    @Override
    public String toString() {
        return "PayloadWrapper{" +
                "title=" + payload.getTitle() +", body=" + payload.getBody()+", channel=" + payload.getChannel()+", notification_channel=" + payload.getNotificationChannel()
                +", silent_push=" + payload.isSilentPush()+", sound=" + payload.getSound()+", rich_media_url=" + payload.getRichPushMediaURL()+", vibes_collapse_id=" + payload.getVibesCollapseId()
                +", priority=" + payload.getPriority()+", custom_client_data=" + payload.getCustomClientData()+ '}';
    }
}
