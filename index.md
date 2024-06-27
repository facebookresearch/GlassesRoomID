---
layout: default
---

<script src="https://cdn.rawgit.com/download/polymer-cdn/1.5.0/lib/webcomponentsjs/webcomponents-lite.min.js"></script>
<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" crossorigin="anonymous">
<link rel="stylesheet" href="thirdparty/trackswitch-js/trackswitch.min.css" />
<script src="https://code.jquery.com/jquery-3.2.1.min.js" integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4=" crossorigin="anonymous"></script>
<script src="thirdparty/trackswitch-js/trackswitch.min.js"></script>
<script type="text/javascript">
    var settings = {
        onlyradiosolo: true,
        repeat: true,
    };

    jQuery(document).ready(function() {
        jQuery(".player").trackSwitch(settings); 
    });
</script>

# Blind Identification of Binaural Room Impulse Responses from Smart Glasses

This page provides binaural audio examples to accompany the manuscript
> [Thomas Deppisch, Nils Meyer-Kahlen, Sebastia Amengual Gari, "Blind Identification of Binaural Room Impulse Responses from Smart Glasses", arXiv:2403.19217, 2024.](https://arxiv.org/abs/2403.19217)

## Listening Experiment
The proposed method was evaluated in a listening experiment where participants had to answer which of the test samples _was recorded in the same room as the reference_. The order of stimuli and trials was randomized, and the stimuli were only refered to as _Reference_, _A_, and _B_. For more details please see Sec. VI in the manuscript. Below you find examples of stimuli from a few trials. All stimuli of all trials are available at the [GitHub repository](https://github.com/facebookresearch/GlassesRoomID/tree/main/experimentStimuli).

The following examples compare the reference to an estimate from the same room and to a measurement from a different room.
<div class="player">
    <ts-track title="Reference MeetingRoom">
        <ts-source src="experimentStimuli/trial1_reference_meetingRoom_male_l.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom">
        <ts-source src="experimentStimuli/trial1_estimate_meetingRoom_male_r.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement LabRoomDry">
        <ts-source src="experimentStimuli/trial1_other_labRoomDry_male_r.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference LabRoomDry">
        <ts-source src="experimentStimuli/trial82_reference_labRoomDry_female_r.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry">
        <ts-source src="experimentStimuli/trial82_estimate_labRoomDry_female_l.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement LabRoomRev">
        <ts-source src="experimentStimuli/trial82_other_labRoomRev_female_l.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference LabRoomRev">
        <ts-source src="experimentStimuli/trial41_reference_labRoomRev_female_l.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev">
        <ts-source src="experimentStimuli/trial41_estimate_labRoomRev_female_r.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement MeetingRoom">
        <ts-source src="experimentStimuli/trial41_other_meetingRoom_female_r.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference LabRoomRev">
        <ts-source src="experimentStimuli/trial66_reference_labRoomRev_male_l.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev">
        <ts-source src="experimentStimuli/trial66_estimate_labRoomRev_male_r.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement LabRoomDry">
        <ts-source src="experimentStimuli/trial66_other_labRoomDry_male_r.wav"></ts-source>
    </ts-track>
</div>

The following examples compare the reference to an estimate from the same room and to a measurement from the same room.
<div class="player">
    <ts-track title="Reference MeetingRoom">
        <ts-source src="experimentStimuli/trial5_reference_meetingRoom_male_l.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom">
        <ts-source src="experimentStimuli/trial5_estimate_meetingRoom_male_r.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement MeetingRoom">
        <ts-source src="experimentStimuli/trial5_same_meetingRoom_male_r.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference LabRoomRev">
        <ts-source src="experimentStimuli/trial60_reference_labRoomRev_female_r.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev">
        <ts-source src="experimentStimuli/trial60_estimate_labRoomRev_female_l.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement LabRoomRev">
        <ts-source src="experimentStimuli/trial60_same_labRoomRev_female_l.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference LabRoomDry">
        <ts-source src="experimentStimuli/trial40_reference_labRoomDry_female_l.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry">
        <ts-source src="experimentStimuli/trial40_estimate_labRoomDry_female_r.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement LabRoomDry">
        <ts-source src="experimentStimuli/trial40_same_labRoomDry_female_r.wav"></ts-source>
    </ts-track>
</div>

The following examples compare the reference to a measurement from the same room and to a measurement from a different room.
<div class="player">
    <ts-track title="Reference MeetingRoom">
        <ts-source src="experimentStimuli/trial3_reference_meetingRoom_male_l.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement MeetingRoom">
        <ts-source src="experimentStimuli/trial3_same_meetingRoom_male_r.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement LabRoomDry">
        <ts-source src="experimentStimuli/trial3_other_labRoomDry_male_r.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference LabRoomRev">
        <ts-source src="experimentStimuli/trial58_reference_labRoomRev_female_r.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement LabRoomRev">
        <ts-source src="experimentStimuli/trial58_same_labRoomRev_female_l.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement MeetingRoom">
        <ts-source src="experimentStimuli/trial58_other_meetingRoom_female_l.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference LabRoomDry">
        <ts-source src="experimentStimuli/trial24_reference_labRoomDry_male_r.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement LabRoomDry">
        <ts-source src="experimentStimuli/trial24_same_labRoomDry_male_l.wav"></ts-source>
    </ts-track>
    <ts-track title="Measurement LabRoomRev">
        <ts-source src="experimentStimuli/trial24_other_labRoomRev_male_l.wav"></ts-source>
    </ts-track>
</div>

## Audio Examples from Non-Ideal Estimation Conditions
The following binaural audio examples showcase renderings under non-ideal estimation conditions (see Sec. V and especially V-F in the manuscript).

Estimation with additive babble noise of varying signal-to-noise ratio (SNR):
<div class="player">
    <ts-track title="Reference LabRoomDry">
        <ts-source src="additionalRenderings/noise/labRoomDryRightLsp_gt.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, infinite SNR">
        <ts-source src="additionalRenderings/noise/labRoomDryRightLsp_resynth_snrInf.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 20 dB SNR">
        <ts-source src="additionalRenderings/noise/labRoomDryRightLsp_resynth_snr20.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 12 dB SNR">
        <ts-source src="additionalRenderings/noise/labRoomDryRightLsp_resynth_snr12.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 6 dB SNR">
        <ts-source src="additionalRenderings/noise/labRoomDryRightLsp_resynth_snr6.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference LabRoomRev">
        <ts-source src="additionalRenderings/noise/labRoomRevLeftLsp_gt.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, infinite SNR">
        <ts-source src="additionalRenderings/noise/labRoomRevLeftLsp_resynth_snrInf.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 20 dB SNR">
        <ts-source src="additionalRenderings/noise/labRoomRevLeftLsp_resynth_snr20.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 12 dB SNR">
        <ts-source src="additionalRenderings/noise/labRoomRevLeftLsp_resynth_snr12.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 6 dB SNR">
        <ts-source src="additionalRenderings/noise/labRoomRevLeftLsp_resynth_snr6.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference MeetingRoom">
        <ts-source src="additionalRenderings/noise/meetingRoomLeftLsp_gt.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, infinite SNR">
        <ts-source src="additionalRenderings/noise/meetingRoomLeftLsp_resynth_snrInf.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 20 dB SNR">
        <ts-source src="additionalRenderings/noise/meetingRoomLeftLsp_resynth_snr20.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 12 dB SNR">
        <ts-source src="additionalRenderings/noise/meetingRoomLeftLsp_resynth_snr12.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 6 dB SNR">
        <ts-source src="additionalRenderings/noise/meetingRoomLeftLsp_resynth_snr6.wav"></ts-source>
    </ts-track>
</div>

Estimation with inaccurate DOA (varying DOA offset):
<div class="player">
    <ts-track title="Reference LabRoomDry">
        <ts-source src="additionalRenderings/doaOffset/labRoomDryRightLsp_gt.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 0 deg offset">
        <ts-source src="additionalRenderings/doaOffset/labRoomDryRightLsp_resynth_doaOffset0.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 10 deg offset">
        <ts-source src="additionalRenderings/doaOffset/labRoomDryRightLsp_resynth_doaOffset10.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 20 deg offset">
        <ts-source src="additionalRenderings/doaOffset/labRoomDryRightLsp_resynth_doaOffset20.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 40 deg offset">
        <ts-source src="additionalRenderings/doaOffset/labRoomDryRightLsp_resynth_doaOffset40.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 60 deg offset">
        <ts-source src="additionalRenderings/doaOffset/labRoomDryRightLsp_resynth_doaOffset60.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 90 deg offset">
        <ts-source src="additionalRenderings/doaOffset/labRoomDryRightLsp_resynth_doaOffset90.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference LabRoomRev">
        <ts-source src="additionalRenderings/doaOffset/labRoomRevLeftLsp_gt.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 0 deg offset">
        <ts-source src="additionalRenderings/doaOffset/labRoomRevLeftLsp_resynth_doaOffset0.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 10 deg offset">
        <ts-source src="additionalRenderings/doaOffset/labRoomRevLeftLsp_resynth_doaOffset10.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 20 deg offset">
        <ts-source src="additionalRenderings/doaOffset/labRoomRevLeftLsp_resynth_doaOffset20.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 40 deg offset">
        <ts-source src="additionalRenderings/doaOffset/labRoomRevLeftLsp_resynth_doaOffset40.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 60 deg offset">
        <ts-source src="additionalRenderings/doaOffset/labRoomRevLeftLsp_resynth_doaOffset60.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 90 deg offset">
        <ts-source src="additionalRenderings/doaOffset/labRoomRevLeftLsp_resynth_doaOffset90.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference MeetingRoom">
        <ts-source src="additionalRenderings/doaOffset/meetingRoomLeftLsp_gt.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 0 deg offset">
        <ts-source src="additionalRenderings/doaOffset/meetingRoomLeftLsp_resynth_doaOffset0.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 10 deg offset">
        <ts-source src="additionalRenderings/doaOffset/meetingRoomLeftLsp_resynth_doaOffset10.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 20 deg offset">
        <ts-source src="additionalRenderings/doaOffset/meetingRoomLeftLsp_resynth_doaOffset20.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 40 deg offset">
        <ts-source src="additionalRenderings/doaOffset/meetingRoomLeftLsp_resynth_doaOffset40.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 60 deg offset">
        <ts-source src="additionalRenderings/doaOffset/meetingRoomLeftLsp_resynth_doaOffset60.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 90 deg offset">
        <ts-source src="additionalRenderings/doaOffset/meetingRoomLeftLsp_resynth_doaOffset90.wav"></ts-source>
    </ts-track>
</div>

Estimation with directional interference of varying signal-to-interference ratio (SIR):
<div class="player">
    <ts-track title="Reference LabRoomDry">
        <ts-source src="additionalRenderings/interference/labRoomDryLeftLsp_gt.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, infinite SIR">
        <ts-source src="additionalRenderings/interference/labRoomDryLeftLsp_resynth_snrInf.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 20 dB SIR">
        <ts-source src="additionalRenderings/interference/labRoomDryLeftLsp_resynth_snr20.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 12 dB SIR">
        <ts-source src="additionalRenderings/interference/labRoomDryLeftLsp_resynth_snr12.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 6 dB SIR">
        <ts-source src="additionalRenderings/interference/labRoomDryLeftLsp_resynth_snr6.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomDry, 0 dB SIR">
        <ts-source src="additionalRenderings/interference/labRoomDryLeftLsp_resynth_snr0.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference LabRoomRev">
        <ts-source src="additionalRenderings/interference/labRoomRevRightLsp_gt.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, infinite SIR">
        <ts-source src="additionalRenderings/interference/labRoomRevRightLsp_resynth_snrInf.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 20 dB SIR">
        <ts-source src="additionalRenderings/interference/labRoomRevRightLsp_resynth_snr20.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 12 dB SIR">
        <ts-source src="additionalRenderings/interference/labRoomRevRightLsp_resynth_snr12.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 6 dB SIR">
        <ts-source src="additionalRenderings/interference/labRoomRevRightLsp_resynth_snr6.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate LabRoomRev, 0 dB SIR">
        <ts-source src="additionalRenderings/interference/labRoomRevRightLsp_resynth_snr0.wav"></ts-source>
    </ts-track>
</div>

<div class="player">
    <ts-track title="Reference MeetingRoom">
        <ts-source src="additionalRenderings/interference/meetingRoomLeftLsp_gt.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, infinite SIR">
        <ts-source src="additionalRenderings/interference/meetingRoomLsp_resynth_snrInf.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 20 dB SIR">
        <ts-source src="additionalRenderings/interference/meetingRoomLsp_resynth_snr20.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 12 dB SIR">
        <ts-source src="additionalRenderings/interference/meetingRoomLsp_resynth_snr12.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 6 dB SIR">
        <ts-source src="additionalRenderings/interference/meetingRoomLsp_resynth_snr6.wav"></ts-source>
    </ts-track>
    <ts-track title="Estimate MeetingRoom, 0 dB SIR">
        <ts-source src="additionalRenderings/interference/meetingRoomLsp_resynth_snr0.wav"></ts-source>
    </ts-track>
</div>

## Ringing and Resynthesis
The following binaural audio example showcases ringing that occurs in a raw BRIR estimate and suppression of the ringing using the proposed resynthesis method. See Sec. IV in the manuscript for details. Note that we deliberately choose an example where strong ringing occured.
<div class="player">
    <ts-track title="Reference">
        <ts-source src="ringingExample/meetingRoom_binaural_groundTruth.wav"></ts-source>
    </ts-track>
    <ts-track title="Raw Estimate">
        <ts-source src="ringingExample/meetingRoom_binaural_estimate.wav"></ts-source>
    </ts-track>
    <ts-track title="Resynthesized Estimate">
        <ts-source src="ringingExample/meetingRoom_binaural_resynthesized.wav"></ts-source>
    </ts-track>
</div>