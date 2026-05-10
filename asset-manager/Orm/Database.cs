using System.Data;
using Microsoft.Data.SqlClient;

namespace AssetManager.Orm
{
    public sealed class Database(string connectionString) : IDisposable
    {
        private readonly SqlConnection connection = new(connectionString);
        private SqlTransaction? transaction;

        public void Open()
        {
            if (connection.State != ConnectionState.Open)
            {
                connection.Open();
            }
        }

        public void Close()
        {
            connection.Close();
        }

        public void BeginTransaction()
        {
            transaction = connection.BeginTransaction(IsolationLevel.Serializable);
        }

        public void Commit()
        {
            if (transaction is null)
            {
                return;
            }

            transaction.Commit();
            transaction.Dispose();
            transaction = null;
        }

        public void Rollback()
        {
            if (transaction is null)
            {
                return;
            }

            transaction.Rollback();
            transaction.Dispose();
            transaction = null;
        }

        public SqlCommand CreateCommand(string commandText)
        {
            SqlCommand command = connection.CreateCommand();
            command.CommandText = commandText;

            if (transaction is not null)
            {
                command.Transaction = transaction;
            }

            return command;
        }

        public void Dispose()
        {
            transaction?.Dispose();
            connection.Dispose();
        }
    }
}
