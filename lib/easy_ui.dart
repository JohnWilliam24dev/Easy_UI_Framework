/// Easy UI: camada declarativa de UI sobre Flutter.
///
/// Este é o único ponto de entrada público do package. Tudo em `src/` é
/// interno; o que o app pode usar é exportado explicitamente aqui.
library;

export 'src/kernel/unit_system/unit_system.dart'
    show Dimension, Fr, Percent, Px, UnitNumExtension, Vh, Vw;
export 'src/kernel/responsive/responsive.dart'
    show
        Breakpoints,
        Responsive,
        ResponsiveResolver,
        ResponsiveValue,
        ScreenSize;
export 'src/theme_layer/theme_layer.dart'
    show
        AppTheme,
        AppThemeController,
        AppThemeMode,
        AppThemeScope,
        ButtonStyleSpec,
        CardVariant,
        CardStyleSpec,
        ElevationLevel,
        InputStyleKind,
        InputLabelPosition,
        InputStyleSpec,
        LabelStyleSpec,
        KanbanStyleSpec,
        ListItemStyleSpec,
        ModalStyleSpec,
        MotionStyleSpec,
        NavStyle,
        NavStyleSpec,
        StylePack,
        StylePackScope,
        ThemeTokens;
export 'src/theme_layer/tokens/theme_tokens.dart' show tint;
export 'src/kernel/layout_engine/layout.dart'
    show
        LayoutDirection,
        LayoutDirectionValue,
        LayoutItem,
        LayoutPosition,
        LayoutProps,
        ResponsiveDirection;
export 'src/kernel/scroll/scroll.dart' show EdgeAutoScroller;
export 'src/formatting/formatting.dart'
    show formatDate, formatDateTime, formatMoney, formatPercent, parseDecimal;
export 'src/widget_catalog/widget_catalog.dart'
    show
        Avatar,
        AvatarSize,
        Backdrop,
        Badge,
        BadgeColor,
        BadgeVariant,
        Button,
        ButtonSize,
        ButtonVariant,
        BarChart,
        Card,
        ChartCard,
        ChartValue,
        DataList,
        DataField,
        DataSource,
        Div,
        Divider,
        EasyApp,
        EmptyState,
        ErrorState,
        AsyncView,
        FormGroup,
        Grid,
        Icon,
        IconAction,
        Link,
        IconBadge,
        ImageField,
        InputField,
        InputType,
        OptionGroup,
        Picture,
        Reveal,
        Label,
        LabelType,
        Loader,
        LoaderMode,
        Legend,
        ListItem,
        Modal,
        Menu,
        Nav,
        PageDots,
        Select,
        SelectOption,
        Section,
        Stat,
        StatGrid,
        TabItem,
        Tabs,
        Tela,
        Toast,
        ToastType,
        Toggle,
        ToggleType;

export 'src/widget_catalog/display/charts.dart' show DonutChart, ProgressBar;
export 'src/widget_catalog/feedback/optimistic.dart' show optimistic;
export 'src/widget_catalog/feedback/user_facing_exception.dart'
    show UserFacingException;
export 'src/widget_catalog/app/app_shell.dart' show AppShell, NavDestination;
export 'src/widget_catalog/auth/auth_page.dart' show AuthPage;
export 'src/widget_catalog/data/resource_list.dart' show Field, ResourceList;
export 'src/widget_catalog/data/kanban.dart'
    show KanbanBoard, KanbanColumnData, KanbanMove, KanbanColumnMove;
export 'src/widget_catalog/feedback/modal.dart' show ModalChoice;

export 'package:flutter/material.dart' show Icons;

export 'src/widget_catalog/inputs/form/form_group.dart' show FormGroup;
export 'src/widget_catalog/inputs/form/validators.dart'
    show
        FormValues,
        Validator,
        isEmail,
        isCurrency,
        isNumber,
        isPassword,
        isRequiredValue,
        isRequired,
        lengthBetween,
        matches,
        maxLength,
        max,
        min,
        minLength,
        sameAs;
