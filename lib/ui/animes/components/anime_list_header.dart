import 'package:flutter/material.dart';
import '../view_model/anime_list_view_model.dart';
import 'package:animeishi/model/factory/anime_list_factory.dart';

class AnimeListHeader extends StatefulWidget {
  final AnimeListViewModel viewModel;
  final VoidCallback onFetchFromServer;
  final VoidCallback onSaveSelected;

  const AnimeListHeader({
    Key? key,
    required this.viewModel,
    required this.onFetchFromServer,
    required this.onSaveSelected,
  }) : super(key: key);

  @override
  _AnimeListHeaderState createState() => _AnimeListHeaderState();
}

class _AnimeListHeaderState extends State<AnimeListHeader> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 16),
            _buildSortSection(),
            SizedBox(height: 16),
            _buildFetchButton(),
            SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF667eea).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => widget.viewModel.searchAnime(value),
        decoration: InputDecoration(
          hintText: 'アニメを検索... (タイトル、読み、TID、年代)',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: Container(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.search,
              color: Color(0xFF667eea),
              size: 20,
            ),
          ),
          suffixIcon: widget.viewModel.searchQuery.isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        _searchController.clear();
                        widget.viewModel.searchAnime('');
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey.shade600,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: TextStyle(
          color: Color(0xFF2D3748),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSortSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF667eea).withOpacity(0.1),
            Color(0xFF764ba2).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF667eea).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.sort, color: Color(0xFF667eea), size: 20),
          SizedBox(width: 8),
          Text(
            'ソート順:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF667eea).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: DropdownButton<SortOrder>(
                value: widget.viewModel.sortOrder,
                underline: SizedBox.shrink(),
                isExpanded: true,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
                onChanged: (SortOrder? newValue) {
                  if (newValue != null) {
                    widget.viewModel.setSortOrder(newValue);
                  }
                },
                items: [
                  DropdownMenuItem(value: SortOrder.tid, child: Text('TID順')),
                  DropdownMenuItem(value: SortOrder.year, child: Text('年代順')),
                  DropdownMenuItem(value: SortOrder.name, child: Text('名前順')),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea).withOpacity(0.8),
                  Color(0xFF764ba2).withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: widget.viewModel.toggleSortOrder,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    widget.viewModel.isAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFetchButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.viewModel.isLoading
              ? [Colors.grey.shade400, Colors.grey.shade500]
              : [Color(0xFF48BB78), Color(0xFF38A169)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.viewModel.isLoading
                ? Colors.grey.withOpacity(0.3)
                : Color(0xFF48BB78).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.viewModel.isLoading ? null : widget.onFetchFromServer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.viewModel.isLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
              ] else ...[
                Icon(Icons.cloud_download_outlined,
                    color: Colors.white, size: 20),
                SizedBox(width: 12),
              ],
              Text(
                widget.viewModel.isLoading ? '取得中...' : 'オンラインから取得',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasSelected = widget.viewModel.selectedAnime.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasSelected
              ? [Color(0xFF667eea), Color(0xFF764ba2)]
              : [Colors.grey.shade300, Colors.grey.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: hasSelected
                ? Color(0xFF667eea).withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: hasSelected ? widget.onSaveSelected : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_add,
                color: hasSelected ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                hasSelected
                    ? '登録 (${widget.viewModel.selectedAnime.length}件)'
                    : 'アニメを選択してください',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: hasSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
