%%传感器阵列波束优化设计与应用
%%20181215
%%myuzhao
clc;
clear;
close all;
M = 10;
snaps_all = [M 2*M 6*M 12*M];
snr_all = -20:5:40;
Monte_Carlo = 200;
SINR_SMI = zeros(length(snaps_all),length(snr_all));
w2 = zeros(length(snaps_all),length(snr_all));
rand_state = 0;
rng('default');
rng(rand_state);
for i_snaps = 1 :length(snaps_all)
    for i_snr = 1:1:length(snr_all)
        snaps = snaps_all(i_snaps);
        for i_M = 1:1:Monte_Carlo
            noise = 1/sqrt(2)*(randn(M,snaps)+1i*randn(M,snaps));%高斯复噪声
            snr0 = snr_all(i_snr);
            angle0 = 0;
            s0 = randn(1, snaps) ;%;exp(1i*2*pi*f*(1/fs:1/fs:snaps/fs));%
            as0 = 10^(snr0/20)*exp(-1i*pi*(0:1:M-1)'*sind(angle0)) * s0; 

            inr1 = 30;
            angle1 = 20;
            s1 = randn(1, snaps) ;%;exp(1i*2*pi*(f+100)*(1/fs:1/fs:snaps/fs)+1i*2*pi*rand(1));%randn(1, snaps);
            an1 = 10^(inr1/20)*exp(-1i*pi*(0:1:M-1)'*sind(angle1)) * s1; 

            inr2 = 35;
            angle2 = 35;
            s2 = randn(1, snaps) ;%;exp(1i*2*pi*(f+200)*(1/fs:1/fs:snaps/fs)+1i*2*pi*rand(1));%randn(1, snaps);
            an2 = 10^(inr2/20)*exp(-1i*pi*(0:1:M-1)'*sind(angle2)) * s2; 

            as_all = as0 + an1 + an2 + noise; %%接收的数据
            R = (as_all*as_all')/(snaps);     %%数据协方差矩阵

%           Rin = ((an1+an2+noise)*(an1+an2+noise)')/snaps;%%干扰和噪声协方差矩阵
            Rin = (an1*an1' + an2*an2'+ noise*noise')/snaps;%%干扰和噪声协方差矩阵
            as = exp(-1i*pi*(0:M-1)'*sind(angle0));
            a_int1 = exp(-1i*pi*(0:M-1)'*sind(angle1));
            a_int2 = exp(-1i*pi*(0:M-1)'*sind(angle2));
            %%%MVDR CAPON
            iRin = inv(Rin);
            w_opt = iRin*as/(as'*iRin*as);
            %%%SMI 
            iR = inv(R);
            w_smi = iR*as/(as'*iR*as);% ;% 
            %%%%%%% *10^(snr0/10)%
           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %               不能使用这种方法，会存在R的计算误差。
% %             SINR_SMI(i_snr, i_snaps) = SINR_SMI(i_snr, i_snaps) +...
% %                    abs(w_smi'*R*w_smi)/abs(w_smi'*Rin*w_smi);%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            SINR_SMI(i_snaps, i_snr) = SINR_SMI(i_snaps, i_snr) +...
                  10^(snr0/10)*abs(w_smi'*as)^2/...
                  (10^(inr1/10)*abs(w_smi'*a_int1)^2+10^(inr2/10)*abs(w_smi'*a_int2)^2+w_smi'*w_smi);  
            w2(i_snaps, i_snr)  = w2(i_snaps, i_snr) + norm(w_smi,2)^2;    
        end
        SINR_SMI(i_snaps, i_snr) = SINR_SMI(i_snaps, i_snr)/Monte_Carlo;
        w2(i_snaps, i_snr) =  w2(i_snaps, i_snr)/Monte_Carlo;
    end
    figure(1)
    plot(snr_all ,10*log10(abs(SINR_SMI(i_snaps,:))))
    hold on
    
    figure(2)
    plot(snr_all ,10*log10(abs(w2(i_snaps,:))))
    hold on
    
    
end
SINR_OPT = snr_all + 10*log10(M);
figure(1)
plot(snr_all,SINR_OPT,'k--')
ylim([-20 50])
xlim([min(snr_all) max(snr_all)])
xlabel('SNR/dB');ylabel('SINR/dB');
legend('N = 1M','N = 2M','N = 6M','N = 10M','Optimal');
set(gca,'fontsize',16)

figure(2)
ylim([-20 50])
xlim([min(snr_all) max(snr_all)])
xlabel('SNR/dB');ylabel('10log(||w||^2)/dB');
legend('N = 1M','N = 2M','N = 6M','N = 10M');
set(gca,'fontsize',16)