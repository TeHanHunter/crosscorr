      DOUBLE PRECISION FUNCTION CCF(M_L, M_H, WAV, SPEC,
     +     WEIGHT, SN, V_R, SNW, N, M)
c     Calculate the Cross-Correlation Function of a spectrum (wav, spec)
c     using a weighted binary mask using (wrong) 1D Doppler shifting
c     evaluated at a single velocitiy V_R (which includes the
c     barycentric shift) (in km/s). The 1D is good to use for HARPS data
c     and HARPS barycentric header values, but not HPF/NEID with
c     barycorrpy.
c
c     INPUT:
c       M_L - left edges of mask 
c       M_H - right edges of mask
c       WAV - wavelengths in A
c       SPEC - flux of spectrum 
c       WEIGHT - weights of mask
c       SN - Additional SNR scaling factor. *CURRENTLY NOT USED* (=1)
c       V_R - velocity to shift (v-barycentric velocity)
c       SNW - CURRENTLY NOT USED 
c       N - CURRENTLY NOT USED
c       M - CURRENTLY NOT USED
c     
c     OUTPUT:
c        CCF - the resulting CCF evaluated at V_R

      IMPLICIT NONE

c     Speed of light, km/s
      DOUBLE PRECISION C
      PARAMETER (C=2.99792458D5)

      INTEGER N, M, COND
      DOUBLE PRECISION M_L(N), M_H(N), WEIGHT(N)
      DOUBLE PRECISION WAV(M), SPEC(M), SN(M)
      DOUBLE PRECISION V_R, GAMMA, SNW
      DOUBLE PRECISION FRACTION, PIX_INIT, PIX_END
      DOUBLE PRECISION M_LLOC(N), M_HLOC(N)

      INTEGER I, J

C     DOPPLER FACTOR, 1D
      GAMMA = DSQRT(1. + V_R / C) / DSQRT(1. - V_R / C)

C     DOPPLER SHIFT MASK, shifts all the lines in the mask
      DO I=1,N
         M_LLOC(I) = M_L(I) * GAMMA
         M_HLOC(I) = M_H(I) * GAMMA
      END DO

C     I marks where we are in terms of masks. I goes from 1 to N and is
C     the mask line iterator
      I = 1
      CCF = 0.0D0
      
      SNW = 0.0D0
      COND = 0
C     Loop over all wavelengths in the spectrum.
C     J is the wavelength counter. There are M Js
      DO J=2,(M-1)
         PIX_INIT = 0.5*(WAV(J-1) + WAV(J))
         PIX_END  = 0.5*(WAV(J) + WAV(J+1))
C        Loop over the mask indices, I is the iterator. Figure out how many
C        wavelengths there are within that pixel
         DO WHILE ((M_HLOC(I) < PIX_INIT) .and. (COND .eq. 0))
            IF (I .eq. N) THEN
               COND = 1
            END IF
            IF (COND .eq. 0) THEN
               I = I + 1
            END IF
         END DO

C        I: Pixel fully within the mask
         IF ((PIX_END < M_HLOC(I)) .AND. 
     +      (PIX_INIT > M_LLOC(I))) THEN
            CCF = CCF + SPEC(J) * WEIGHT(I) * SN(J)
C            CCF = CCF + SPEC(J) * SN(J)
            SNW = SNW + SN(J)*WEIGHT(I)

C        II: Only right half of pixel within mask
         ELSE IF ((PIX_END < M_HLOC(I)) .AND.
     +           (PIX_INIT < M_LLOC(I)) .AND.
     +           (PIX_END > M_LLOC(I))) THEN
            FRACTION = (PIX_END - M_LLOC(I)) / (PIX_END - PIX_INIT)
            CCF = CCF + SPEC(J) * WEIGHT(I) * FRACTION * SN(J)
C            CCF = CCF + SPEC(J) * FRACTION * SN(J)
            SNW = SNW + FRACTION*SN(J)*WEIGHT(I)

C        III: Only left half of pixel within mask
          ELSE IF ((PIX_END > M_HLOC(I)) .AND.
     +           (PIX_INIT > M_LLOC(I)) .AND.
     +           (PIX_INIT < M_HLOC(I))) THEN
            FRACTION = (M_HLOC(I) - PIX_INIT) / (PIX_END - PIX_INIT)
            CCF = CCF + SPEC(J) * WEIGHT(I) * FRACTION * SN(J)
C            CCF = CCF + SPEC(J) * FRACTION * SN(J)
            SNW = SNW + FRACTION*SN(J)*WEIGHT(I)

C        IV: Only middle part of pixel within mask
         ELSE IF ((PIX_END > M_HLOC(I)) .AND.
     +           (PIX_INIT < M_LLOC(I))) THEN
            FRACTION = (M_HLOC(I) - M_LLOC(I)) / (PIX_END - PIX_INIT)
            CCF = CCF + SPEC(J) * WEIGHT(I) * FRACTION * SN(J)
C            CCF = CCF + SPEC(J) * FRACTION * SN(J)
            SNW = SNW + FRACTION*SN(J)*WEIGHT(I)
         END IF
      END DO

C      CCF = CCF / SNW

      END
