/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useCallback, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Sparkles, Target, Pointer } from 'lucide-react';

// --- Types & Constants ---

enum CoinResult {
  HEADS = '한다.',
  TAILS = '안 한다.',
}

enum AppState {
  IDLE = 'idle',
  FLIPPING = 'flipping',
  LANDED = 'landed',
}

const COLORS = {
  bg: '#FAF9F6',
  headsText: '#431407',
  tailsText: '#7C2D12',
  textMuted: '#A8A29E',
};

// --- Components ---

/**
 * 3D Coin Component
 * Uses CSS 3D transforms managed by Motion
 */
const Coin = ({ 
  result, 
  state, 
  rotation,
  isHolding,
  flipDuration
}: { 
  result: CoinResult | null; 
  state: AppState;
  rotation: number;
  isHolding: boolean;
  flipDuration: number;
}) => {
  return (
    <div className="relative w-48 h-48 [perspective:1000px]">
      <motion.div
        className="w-full h-full relative [transform-style:preserve-3d]"
        animate={{
          rotateX: rotation,
          z: state === AppState.FLIPPING ? 300 : isHolding ? -30 : 0,
          scale: state === AppState.FLIPPING ? 1.4 : isHolding ? 0.95 : 1,
        }}
        transition={{
          rotateX: {
            duration: state === AppState.FLIPPING ? flipDuration : 0.6,
            ease: state === AppState.FLIPPING ? "easeOut" : "backOut"
          },
          z: {
            duration: state === AppState.FLIPPING ? flipDuration / 2 : 0.2,
            repeat: state === AppState.FLIPPING ? 1 : 0,
            repeatType: "reverse",
            ease: state === AppState.FLIPPING ? "easeOut" : "easeInOut"
          },
          scale: {
            duration: state === AppState.FLIPPING ? flipDuration / 2 : 0.2,
            repeat: state === AppState.FLIPPING ? 1 : 0,
            repeatType: "reverse",
            ease: state === AppState.FLIPPING ? "easeOut" : "easeInOut"
          }
        }}
        id="coin-container"
      >
        {/* Front (Heads) */}
        <div 
          className="absolute inset-0 rounded-full flex items-center justify-center shadow-[0_12px_40px_rgb(234,88,12,0.15)] border border-orange-200/60 [backface-visibility:hidden]"
          style={{ background: 'linear-gradient(135deg, #FFF3E0, #FFE0B2)' }}
          id="coin-front"
        >
          <div className="text-3xl font-medium tracking-tight text-orange-950">한다.</div>
          <div className="absolute inset-2 border border-orange-900/10 rounded-full" />
        </div>

        {/* Back (Tails) */}
        <div 
          className="absolute inset-0 rounded-full flex items-center justify-center shadow-[0_12px_40px_rgb(234,88,12,0.15)] border border-orange-200/60 [backface-visibility:hidden] [transform:rotateX(180deg)]"
          style={{ background: 'linear-gradient(135deg, #FFE0B2, #FFCC80)' }}
          id="coin-back"
        >
          <div className="text-3xl font-medium tracking-tight text-orange-900/60 pb-1">안 한다.</div>
          <div className="absolute inset-2 border border-orange-900/10 rounded-full" />
        </div>
      </motion.div>
    </div>
  );
};

export default function App() {
  const [state, setState] = useState<AppState>(AppState.IDLE);
  const [result, setResult] = useState<CoinResult | null>(null);
  const [rotation, setRotation] = useState(0);
  const [isHolding, setIsHolding] = useState(false);
  const [flipDuration, setFlipDuration] = useState(1.5);
  const holdStartTime = useRef(0);

  const handlePointerDown = useCallback((e: React.PointerEvent) => {
    if (e.button !== 0 && e.pointerType === 'mouse') return;
    if (state === AppState.FLIPPING) return;
    
    holdStartTime.current = Date.now();
    setIsHolding(true);
  }, [state]);

  const handlePointerUp = useCallback(() => {
    if (!isHolding || state === AppState.FLIPPING) return;
    
    const duration = Date.now() - holdStartTime.current;
    setIsHolding(false);
    
    const boundedDuration = Math.min(duration, 2000);
    
    const isHeads = Math.random() < 0.5;
    const nextResult = isHeads ? CoinResult.HEADS : CoinResult.TAILS;

    const baseRotations = 3;
    const extraRotations = Math.floor((boundedDuration / 2000) * 15);
    const currentSpins = Math.floor(rotation / 360);
    const finalRotation = (currentSpins + baseRotations + extraRotations) * 360 + (isHeads ? 0 : 180);

    const calculatedDuration = 1.2 + (boundedDuration / 2000) * 1.8;

    setRotation(finalRotation);
    setResult(nextResult);
    setFlipDuration(calculatedDuration);
    setState(AppState.FLIPPING);

    setTimeout(() => {
      setState(AppState.LANDED);
    }, calculatedDuration * 1000);
  }, [isHolding, state, rotation]);

  const handleKeyDown = useCallback((e: React.KeyboardEvent) => {
    if (e.key === ' ' || e.key === 'Enter') {
      e.preventDefault();
      if (state === AppState.FLIPPING) return;
      holdStartTime.current = Date.now();
      setIsHolding(true);
    }
  }, [state]);

  const handleKeyUp = useCallback((e: React.KeyboardEvent) => {
    if (e.key === ' ' || e.key === 'Enter') {
      e.preventDefault();
      handlePointerUp();
    }
  }, [handlePointerUp]);

  return (
    <main 
      className="fixed inset-0 flex flex-col items-center justify-between py-12 select-none overflow-hidden touch-none"
      style={{ backgroundColor: COLORS.bg }}
      onPointerDown={handlePointerDown}
      onPointerUp={handlePointerUp}
      onPointerCancel={handlePointerUp}
      onPointerLeave={handlePointerUp}
      onKeyDown={handleKeyDown}
      onKeyUp={handleKeyUp}
      tabIndex={0}
      role="button"
      aria-label="동전 던지기 — 클릭하거나 스페이스바를 눌러 동전을 던지세요"
      id="main-screen"
    >
      {/* App Title */}
      <motion.div 
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mt-6"
        id="app-header"
      >
        <h1 className="text-stone-800 text-5xl md:text-6xl font-serif tracking-tight">Flip It.</h1>
      </motion.div>

      {/* Center Coin Area */}
      <div className="relative flex items-center justify-center flex-1 w-full" id="coin-area">
        <Coin result={result} state={state} rotation={rotation} isHolding={isHolding} flipDuration={flipDuration} />
        
        {/* Subtle shadow on land, instead of bright glow */}
        <AnimatePresence>
          {state === AppState.LANDED && (
            <motion.div
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1.1, opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute w-48 h-48 rounded-full shadow-[0_20px_60px_rgb(0,0,0,0.06)] pointer-events-none"
              id="land-glow"
            />
          )}
        </AnimatePresence>
      </div>

      {/* Results & Instructions */}
      <div className="text-center h-48 flex flex-col items-center justify-center" id="footer-area" aria-live="polite" aria-atomic="true">
        <AnimatePresence mode="wait">
          {state === AppState.LANDED ? (
            <motion.div
              key="result"
              initial={{ opacity: 0, scale: 0.5, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              className="flex flex-col items-center"
              id="result-display"
            >
              <div 
                className="text-4xl font-serif tracking-tight mb-2 text-stone-800"
              >
                {result}
              </div>
              <motion.div 
                animate={{ opacity: [0.5, 1, 0.5] }}
                transition={{ duration: 2, repeat: Infinity }}
                className="text-amber-700/60 text-sm mt-4 flex items-center gap-2 font-medium"
              >
                <Pointer className="w-4 h-4 rotate-180" />
                다시 던지려면 터치하세요
              </motion.div>
            </motion.div>
          ) : state === AppState.IDLE ? (
            <motion.div
              key="idle"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="flex flex-col items-center"
              id="idle-display"
            >
              <div 
                className="text-stone-700 text-lg font-medium mb-1 transition-transform duration-300"
                style={{ transform: isHolding ? 'scale(1.05)' : 'scale(1)' }}
              >
                {isHolding ? '이제 손을 떼세요! 🎯' : '가볍게 누르거나 길게 꾹 눌러보세요 👆'}
              </div>
              <div className="text-stone-400 text-sm">
                길게 누르면 동전이 더 많이 회전합니다
              </div>
            </motion.div>
          ) : (
            <motion.div
              key="flipping"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="text-stone-400 text-sm animate-pulse font-medium"
              id="flipping-display"
            >
              결정하는 중...
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Audio toggle placeholder (UI only for now) */}
      <div className="absolute top-6 right-6" id="settings-area">
        <button className="p-2 text-stone-300 hover:text-stone-500 transition-colors" aria-label="소리 설정">
          {/* Mute icon stub */}
          <svg className="w-7 h-7" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
          </svg>
        </button>
      </div>
    </main>
  );
}
