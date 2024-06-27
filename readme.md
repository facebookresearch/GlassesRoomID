# Blind Identification of Binaural Room Impulse Responses from Smart Glasses

This repository contains a MATLAB reference implementation of the method from the manuscript
> [Thomas Deppisch, Nils Meyer-Kahlen, Sebastia Amengual Gari, "Blind Identification of Binaural Room Impulse Responses from Smart Glasses", arXiv:2403.19217, 2024.](https://arxiv.org/abs/2403.19217)

The file `runBrirIdentification.m` runs the method including the following steps:
- Convolve a measured multichannel RIR with a speech signal and add babble noise
- Dereverberate multichannel signals
- Apply an MVDR beamformer
- Estimate the multichannel RIR using a multichannel Wiener filter
- Resynthesize the RIR estimate using shaped noise
- Render binaurally using end-to-end magLS
- Repeat the estimation with a RIR obtained from the mouth simulator of a dummy head (own voice estimation)
- Calculate evaluation metrics (RT, DRR)
- Run baseline algorithms for comparison
- Display results

## Thirdparty Dependencies
The following dependencies are required to run the BRIR identification. They are **not provided and need to be added manually!** Make sure to install the toolboxes and add the files to your MATLAB path (or the folder `thirdparty`).
- the [STFT Toolbox](https://github.com/tomshlomo/stft)
- the [ITA Toolbox](https://www.ita-toolbox.org/)
- the [KU100 HRIR Set](https://zenodo.org/records/3928297/files/HRIR_L2702.sofa)
- the [SOFA Toolbox](https://github.com/sofacoustics/SOFAtoolbox) for loading the HRIR set

## Files
Supporting functions are provided in the folder `lib` and the folder `data` contains the RIRs, anechoic array transfer functions for the beamforming, and a dry speech signal. 

We provide 8-channel RIRs captured with microphones on a pair of glasses from 3 different rooms/acoustic settings: A conference room of dimensions 6.02 x 5.87 x 2.73 m, and a lab room ([same as here](https://github.com/facebookresearch/R3VIVAL)) of dimensions 9.7 x 5.5 x 2.7 m that has been measured with 2 different acoustic settings. 
(A "dry" setting with acoustic wall panels turned to their absorbing side, and a "reverberant" setting with the panels turned to their reflecting side).

The folder `experimentStimuli` contains the binaural renderings that were used in the listening experiment. In the experiment, the order of trials and the order of stimuli within a trial were randomized and unknown to the participants. 
Each trial contains a reference stimulus to which the other stimuli were compared, and the question 'Which voice was recorded in the same room as the reference?' had to be answered. Please refer to section VII in the manuscript for more details.

The folder `ringingExample` contains wav files to demonstrate ringing artifacts that can occur in the RIR estimates. We provide binaural renderings of a speech sample that is filtered with the measured RIR, the estimated (ringing) RIR, and the resynthesized RIR. Please refer to section IV in the manuscript for details.

## Contributing
See the [CONTRIBUTING](CONTRIBUTING.md) file for how to help out.

## License
GlassesRoomID is CC-BY-NC 4.0 licensed, as found in the [LICENSE](LICENSE) file.
