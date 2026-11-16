# Slivers & Physics Animation Reference

## 1. CustomScrollView Structure
Always prefer `CustomScrollView` for non-trivial scroll surfaces:
```dart
CustomScrollView(
  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
  slivers: [
    SliverAppBar.medium(
      title: const Text('Title'),
      expandedHeight: 200.0,
      flexibleSpace: FlexibleSpaceBar(...),
    ),
    SliverPersistentHeader(
      pinned: true,
      delegate: TabBarHeaderDelegate(...),
    ),
    SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ItemWidget(items[index]),
    ),
  ],
)
```

## 2. RepaintBoundary Optimization
When animating:
```dart
RepaintBoundary(
  child: AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      return Transform.rotate(
        angle: _controller.value * 2 * math.pi,
        child: child, // keep static child outside builder
      );
    },
    child: const HeavyStaticWidget(),
  ),
)
```
