import 'package:flutter/material.dart';
import '../theme.dart';

class RPGCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final bool fancy;
  final String? backgroundImage;
  final String? borderType;

  const RPGCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
    this.onTap,
    this.fancy = false,
    this.backgroundImage,
    this.borderType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: elevation ?? 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: fancy ? AppTheme.goldAccent : AppTheme.goldAccent.withValues(alpha: 0.3),
                width: fancy ? 3 : 1,
              ),
              image: backgroundImage != null
                  ? DecorationImage(
                      image: AssetImage(backgroundImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
              gradient: fancy
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.darkBackground,
                        AppTheme.mediumBackground,
                      ],
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class RPGButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? color;
  final double? elevation;
  final bool fancy;
  final EdgeInsets? padding;

  const RPGButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.elevation,
    this.fancy = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (color ?? AppTheme.goldAccent).withValues(alpha: 0.5),
            blurRadius: elevation ?? 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Ink(
            decoration: BoxDecoration(
              color: color ?? AppTheme.goldAccent,
              borderRadius: BorderRadius.circular(30),
              gradient: fancy
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.goldAccent,
                        AppTheme.goldAccent.withValues(alpha: 0.8),
                      ],
                    )
                  : null,
            ),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class RPGText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const RPGText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      color: AppTheme.goldAccent,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [
            AppTheme.goldAccent,
            AppTheme.goldAccent.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: style ?? defaultStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

class RPGAvatar extends StatelessWidget {
  final String avatarType;
  final double size;
  final bool glowing;

  const RPGAvatar({
    super.key,
    required this.avatarType,
    this.size = 80,
    this.glowing = true,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> avatarImages = {
      'warrior': 'assets/images/warrior_avatar.png',
      'mage': 'assets/images/mage_avatar.png',
      'ranger': 'assets/images/ranger_avatar.png',
      'healer': 'assets/images/healer_avatar.png',
      'merchant': 'assets/images/merchant_avatar.png',
      'executive': 'assets/images/executive_avatar.png',
      'entrepreneur': 'assets/images/entrepreneur_avatar.png',
      'manager': 'assets/images/manager_avatar.png',
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: AppTheme.goldAccent.withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: CircleAvatar(
        backgroundColor: AppTheme.goldAccent.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ClipOval(
            child: Image.asset(
              avatarImages[avatarType] ?? 'assets/images/warrior_avatar.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback when asset not found
                return Container(
                  color: AppTheme.darkBackground,
                  child: Icon(
                    Icons.person,
                    color: AppTheme.goldAccent,
                    size: size * 0.6,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class RPGProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool fancy;

  const RPGProgressBar({
    super.key,
    required this.progress,
    this.height = 16,
    this.backgroundColor,
    this.progressColor,
    this.fancy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: backgroundColor ?? AppTheme.darkBackground,
        border: Border.all(
          color: AppTheme.goldAccent.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: backgroundColor ?? AppTheme.darkBackground,
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: fancy
                      ? LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            progressColor ?? AppTheme.goldAccent,
                            (progressColor ?? AppTheme.goldAccent).withValues(alpha: 0.7),
                          ],
                        )
                      : null,
                  color: fancy ? null : (progressColor ?? AppTheme.goldAccent),
                ),
              ),
            ),
            if (fancy)
              Positioned(
                top: 0,
                bottom: 0,
                left: (progress * MediaQuery.of(context).size.width).clamp(
                  0.0,
                  MediaQuery.of(context).size.width,
                ),
                child: Container(
                  width: 4,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 5,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class XPBar extends StatelessWidget {
  final int currentXP;
  final int maxXP;
  final int level;
  final double height;

  const XPBar({
    super.key,
    required this.currentXP,
    required this.maxXP,
    required this.level,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxXP > 0 ? currentXP / maxXP : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nível $level',
              style: TextStyle(
                color: AppTheme.lightTextColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$currentXP / $maxXP XP',
              style: TextStyle(
                color: AppTheme.lightTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        RPGProgressBar(
          progress: progress,
          height: height,
          backgroundColor: AppTheme.darkBackground,
          progressColor: AppTheme.goldAccent,
          fancy: true,
        ),
      ],
    );
  }
}

class RPGDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget>? actions;
  final Widget? child;

  const RPGDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: RPGCard(
        fancy: true,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppTheme.goldAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (child != null) 
              child!
            else
              Text(
                content,
                style: TextStyle(
                  color: AppTheme.lightTextColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            if (actions != null) ...actions! else
            RPGButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}