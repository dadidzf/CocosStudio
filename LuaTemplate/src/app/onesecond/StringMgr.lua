local StringMgr = 
{
    cn = 
    {
        startTips = "点击开始",
        gameOver = "游戏结束",
        gameTips = "一秒钟多久?",
        oneSecondTips = "长按一秒钟",
        bestScore = "最高分"
    },    
    jp = 
    {
        startTips = "開始するにはタップ",
        gameOver = "ゲームオーバー",
        gameTips = "1秒間の長さ ?",
        oneSecondTips = "1秒間長押し",
        bestScore = "最高スコア"
    },    
    en = 
    {
        startTips = "Tap to start",
        gameOver = "Game Over",
        gameTips = "How long is one second ?",
        oneSecondTips = "Long press for one second",
        bestScore = "Best Score"
    },    
    pt = 
    {
        startTips = "Toque para começar",
        gameOver = "Fim de jogo",
        gameTips = "Quanto tempo é um segundo ?",
        oneSecondTips = "Pressione por um segundo",
        bestScore = "maior pontuação"
    },    
    sp = 
    {
        startTips = "Toque para iniciar",
        gameOver = "Juego terminado",
        gameTips = "¿Cuánto dura un segundo ?",
        oneSecondTips = "Presión prolongada por un segundo",
        bestScore = "puntuación más alta"
    },    
}

print("xxxxxxxxx", device.language)

if StringMgr[device.language] == nil then
    return StringMgr.en
else
    return StringMgr[device.language]
end

